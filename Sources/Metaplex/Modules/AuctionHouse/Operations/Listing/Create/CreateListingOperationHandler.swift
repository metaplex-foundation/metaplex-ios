//
//  CreateListingOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation
import Solana

typealias CreateListingOperation = OperationResult<CreateListingInput, OperationError>

class CreateListingOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = CreateListingInput
    typealias O = Listing

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: CreateListingOperation) -> OperationResult<Listing, OperationError> {
        operation.flatMap { input in
            switch self.createParametersFromInput(input) {
            case .success(let parameters):
                return self.createOperationResult(parameters, auctionHouse: input.auctionHouse)
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    // MARK: - Private Helpers

    private func createParametersFromInput(
        _ input: CreateListingInput
    ) -> Result<CreateListingBuilderParameters, OperationError> {
        let defaultIdentity = metaplex.identity()
        let seller = input.seller ?? defaultIdentity

        guard let metadata = try? MetadataAccount.pda(mintKey: input.mintAccount).get()
        else { return .failure(.couldNotFindMetadata) }

        guard let tokenAccount = input.tokenAccount ?? PublicKey.findAssociatedTokenAccountPda(
            mint: input.mintAccount,
            owner: seller.publicKey
        )
        else { return .failure(.couldNotFindTokenAccount) }

        guard let auctionHouse = input.auctionHouse.address else {
            return .failure(.couldNotFindAuctionHouse)
        }

         guard let sellerTradeStatePda = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouse,
            wallet: seller.publicKey,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.mintAccount,
            buyerPrice: input.price,
            tokenSize: input.tokens,
            tokenAccount: tokenAccount
        ).get()
        else { return .failure(.couldNotFindSellerTradeStatePda) }

        guard let freeSellerTradeState = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouse,
            wallet: seller.publicKey,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.mintAccount,
            buyerPrice: Lamports(),
            tokenSize: input.tokens,
            tokenAccount: tokenAccount
        ).get()
        else { return .failure(.couldNotFindFreeTradeStatePda) }

        guard let programAsSignerPda = try? Auctionhouse.programAsSignerPda().get()
        else { return .failure(.couldNotFindProgramAsSignerPda) }

        let parameters = CreateListingBuilderParameters(
            createListingInput: input,
            sellerTradeStatePda: sellerTradeStatePda,
            freeSellerTradeStatePda: freeSellerTradeState,
            programAsSignerPda: programAsSignerPda,
            defaultIdentity: defaultIdentity,
            tokenAccount: tokenAccount,
            metadata: metadata,
            auctionHouse: auctionHouse
        )
        return .success(parameters)
    }

    private func createOperationResult(
        _ parameters: CreateListingBuilderParameters,
        auctionHouse: AuctionhouseArgs
    ) -> OperationResult<Listing, OperationError> {
        let createListingBuilder = TransactionBuilder.createListingBuilder(parameters: parameters)
        let operation = OperationResult<SignatureStatus, OperationError>.init { callback in
            createListingBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
                switch result {
                case .success(let status):
                    callback(.success(status))
                case .failure(let error):
                    callback(.failure(.confirmTransactionError(error)))
                }
            }
        }.flatMap { status in
            OperationResult<Listing, OperationError>.init { callback in
                if let receipt = parameters.receipt {
                    self.metaplex.auctionHouse.findListingByReceipt(
                        receipt.publicKey,
                        auctionHouse: auctionHouse
                    ) { callback($0) }
                } else {
                    let listing = LazyListing(
                        auctionHouse: auctionHouse,
                        tradeState: Pda(publicKey: parameters.sellerTradeState, bump: parameters.tradeStateBump),
                        bookkeeper: parameters.bookkeeper,
                        seller: parameters.sellerSigner.publicKey,
                        metadata: parameters.metadata,
                        receipt: parameters.receipt,
                        purchaseReceipt: nil,
                        price: parameters.buyerPrice,
                        tokenSize: parameters.tokenSize,
                        createdAt: Int64(Date().timeIntervalSinceNow),
                        canceledAt: nil
                    )
                    self.metaplex.auctionHouse.loadListing(listing) { callback($0) }
                }
            }
        }
        return operation
    }
}
