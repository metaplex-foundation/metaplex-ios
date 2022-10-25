//
//  CreateListingOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation
import Solana

public struct CreateListingInput {
    let auctionHouse: Auctionhouse
    let seller: Account? = nil
    let authority: Account? = nil
    let auctioneerAuthority: Account?
    let mintAccount: PublicKey
    let tokenAccount: PublicKey? = nil
    let price: UInt64 = 0
    let tokens: UInt64 = 1
    let printReceipt: Bool = true
    let bookkeeper: Account? = nil
}

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
            return self.createOperationResult(parameters)
        }
    }

    private func createParametersFromInput(_ input: CreateListingInput) -> CreateListingBuilderParameters? {
        let defaultIdentity = metaplex.identity()
        let seller = input.seller ?? defaultIdentity

        let metadata = try? MetadataAccount.pda(mintKey: input.mintAccount).get()
        let tokenAccount = input.tokenAccount ?? PublicKey.findAssociatedTokenAccountPda(
            mint: input.mintAccount,
            owner: seller.publicKey
        )

        guard let auctionHouseAddress = input.auctionHouse.address else {
            return nil //.failure(.couldNotFindPDA)
        }

        let sellerTradeStatePda = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouseAddress,
            wallet: seller.publicKey,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.mintAccount,
            buyerPrice: input.price,
            tokenSize: input.tokens,
            tokenAccount: tokenAccount
        ).get()

        let freeSellerTradeState = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouseAddress,
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
            metadata: metadata,
            tokenAccount: tokenAccount,
            sellerTradeStatePda: sellerTradeStatePda,
            freeSellerTradeStatePda: freeSellerTradeState,
            programAsSignerPda: programAsSignerPda,
            auctionHouseAddress: auctionHouseAddress,
            defaultIdentity: defaultIdentity
        )
    }

    private func createOperationResult(_ parameters: CreateListingBuilderParameters) -> OperationResult<Listing, OperationError> {
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
                let auctionHouse = parameters.createListingInput.auctionHouse
                if let receipt = parameters.printReceipt.receipt {
                    self.metaplex.auctionHouse.findListingByReceipt(
                        receipt.publicKey,
                        auctionHouse: auctionHouse
                    ) { callback($0) }
                } else {
                    let listing = LazyListing(
                        auctionHouse: auctionHouse,
                        tradeState: parameters.sellerTradeStatePda,
                        bookkeeper: parameters.bookkeeper.publicKey,
                        seller: parameters.seller.publicKey,
                        metadata: parameters.metadata,
                        receipt: parameters.printReceipt.receipt,
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
