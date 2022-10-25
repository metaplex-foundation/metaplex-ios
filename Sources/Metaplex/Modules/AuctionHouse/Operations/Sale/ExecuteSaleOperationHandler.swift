//
//  ExecuteSaleOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/18/22.
//

import AuctionHouse
import Foundation
import Solana

public struct ExecuteSaleInput {
    let bid: Bid
    let listing: Listing
    let auctionHouse: Auctionhouse
    let auctioneerAuthority: Account?
    let bookkeeper: Account? = nil
    let printReceipt: Bool = true
}

typealias ExecuteSaleOperation = OperationResult<ExecuteSaleInput, OperationError>

class ExecuteSaleOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = ExecuteSaleInput
    typealias O = Purchase

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: ExecuteSaleOperation) -> OperationResult<Purchase, OperationError> {
        operation.flatMap { input in
            guard let parameters = self.createParametersFromInput(input) else { return .failure(.couldNotFindPDA) } // TODO: Fix error here, maybe throw from `createParametersFromInput(_:)`
            return self.createOperationResult(parameters)
        }
    }   

    private func createParametersFromInput(_ input: ExecuteSaleInput) -> ExecuteSaleBuilderParameters? {
        let defaultIdentity = metaplex.identity()

        let tokenAccount = PublicKey.findAssociatedTokenAccountPda(
          mint: input.listing.nft.mint,
          owner: input.listing.listingReceipt.seller
        )

        guard let auctionHouseAddress = input.auctionHouse.address else {
            return nil
        }

        let escrowPayment = try? Auctionhouse.buyerEscrowPda(
            auctionHouse: auctionHouseAddress,
            buyer: input.bid.bidReceipt.buyer
        ).get()

        let seller = input.listing.listingReceipt.seller
        let sellerPaymentReceiptAccount = input.auctionHouse.isNative
        ? seller
        : PublicKey.findAssociatedTokenAccountPda(
            mint: input.auctionHouse.treasuryMint,
            owner: seller
        )

        let buyerReceiptTokenAccount = PublicKey.findAssociatedTokenAccountPda(
            mint: input.listing.nft.mint,
            owner: input.bid.bidReceipt.buyer
        )

        #warning("Fix tokenSize.")
        let freeTradeStateAccount = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouseAddress,
            wallet: input.listing.listingReceipt.seller,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.listing.nft.mint,
            buyerPrice: Lamports(),
            tokenSize: Lamports(),
            tokenAccount: tokenAccount
        ).get()

        let programAsSignerAccount = try? Auctionhouse.programAsSignerPda().get()

        guard let tokenAccount,
              let escrowPayment,
              let sellerPaymentReceiptAccount,
              let buyerReceiptTokenAccount,
              let freeTradeStateAccount,
              let programAsSignerAccount else {
            return nil
        }

        return ExecuteSaleBuilderParameters(
            executeSaleInput: input,
            tokenAccount: tokenAccount,
            escrowPayment: escrowPayment,
            sellerPaymentReceiptAccount: sellerPaymentReceiptAccount,
            buyerReceiptTokenAccount: buyerReceiptTokenAccount,
            auctionHouseAddress: auctionHouseAddress,
            freeTradeStateAccount: freeTradeStateAccount,
            programAsSignerAccount: programAsSignerAccount,
            defaultIdentity: defaultIdentity
        )
    }

    private func createOperationResult(_ parameters: ExecuteSaleBuilderParameters) -> OperationResult<Purchase, OperationError> {
        let executeSaleBuilder = TransactionBuilder.executeSaleBuilder(parameters: parameters)
        let operation = OperationResult<SignatureStatus, OperationError>.init { callback in
            executeSaleBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
                switch result {
                case .success(let status):
                    callback(.success(status))
                case .failure(let error):
                    callback(.failure(.confirmTransactionError(error)))
                }
            }
        }.flatMap { status in
            OperationResult<Purchase, OperationError>.init { callback in
                let auctionHouse = parameters.executeSaleInput.auctionHouse
                if let receipt = parameters.printReceipt.receipt {
                    self.metaplex.auctionHouse.findPurchaseByReceipt(
                        receipt.publicKey,
                        auctionHouse: auctionHouse
                    ) { callback($0) }
                } else {
                    let purchase = LazyPurchase(
                        auctionHouse: auctionHouse,
                        buyer: parameters.buyer,
                        seller: parameters.seller,
                        metadata: parameters.metadata,
                        bookkeeper: parameters.bookkeeper.publicKey,
                        receipt: parameters.printReceipt.receipt?.publicKey,
                        price: parameters.buyerPrice,
                        tokenSize: parameters.tokenSize,
                        createdAt: Int64(Date().timeIntervalSinceNow)
                    )
                    self.metaplex.auctionHouse.loadPurchase(purchase) { callback($0) }
                }
            }
        }
        return operation
    }
}
