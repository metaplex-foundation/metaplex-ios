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
            guard let parameters = self.createParametersFromInput(input) else { return .failure(.couldNotFindPDA) } // TODO: Fix error here, maybe throw from `createParametersFromInput(_:)`
            return self.createOperationResult(parameters, auctionHouse: input.auctionHouse)
        }
    }

    // MARK: - Private Helpers

    private func createParametersFromInput(_ input: CreateListingInput) -> CreateListingBuilderParameters? {
        let defaultIdentity = metaplex.identity()
        let seller = input.seller ?? defaultIdentity

        let metadata = try? MetadataAccount.pda(mintKey: input.mintAccount).get()
        let tokenAccount = input.tokenAccount ?? PublicKey.findAssociatedTokenAccountPda(
            mint: input.mintAccount,
            owner: seller.publicKey
        )

        guard let auctionHouse = input.auctionHouse.address else {
            return nil //.failure(.couldNotFindPDA)
        }

        let sellerTradeStatePda = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouse,
            wallet: seller.publicKey,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.mintAccount,
            buyerPrice: input.price,
            tokenSize: input.tokens,
            tokenAccount: tokenAccount
        ).get()

        let freeSellerTradeState = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouse,
            wallet: seller.publicKey,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.mintAccount,
            buyerPrice: Lamports(),
            tokenSize: input.tokens,
            tokenAccount: tokenAccount
        ).get()

        let programAsSignerPda = try? Auctionhouse.programAsSignerPda().get()

        guard let metadata,
              let tokenAccount,
              let sellerTradeStatePda,
              let freeSellerTradeState,
              let programAsSignerPda else {
            return nil // Handle error here
        }

        return CreateListingBuilderParameters(
            createListingInput: input,
            sellerTradeStatePda: sellerTradeStatePda,
            freeSellerTradeStatePda: freeSellerTradeState,
            programAsSignerPda: programAsSignerPda,
            defaultIdentity: defaultIdentity,
            tokenAccount: tokenAccount,
            metadata: metadata,
            auctionHouse: auctionHouse
        )
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
