//
//  ExecuteSaleOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/18/22.
//

import AuctionHouse
import Foundation
import Solana

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
            guard input.isAuctionHouseMatching else { return .failure(.createExecuteSaleError(.auctionHouseMismatchError)) }
            guard input.isMintMatching else { return .failure(.createExecuteSaleError(.mintMismatchError)) }
            guard !input.isBidCancelled else { return .failure(.createExecuteSaleError(.bidCancelledError)) }
            guard !input.isListingCancelled else { return .failure(.createExecuteSaleError(.listingCancelledError)) }
            guard input.isAuctioneerRequired else { return .failure(.createExecuteSaleError(.auctioneerRequiredError)) }
            guard input.isPartialSaleSupported else { return .failure(.createExecuteSaleError(.partialSaleUnsupportedError)) }
            guard let parameters = self.createParametersFromInput(input) else { return .failure(.couldNotFindPDA) } // TODO: Fix error here, maybe throw from `createParametersFromInput(_:)`
            return self.createOperationResult(parameters, auctionHouse: input.auctionHouse)
        }
    }

    // MARK: - Private Helpers

    private func createParametersFromInput(_ input: ExecuteSaleInput) -> ExecuteSaleBuilderParameters? {
        let defaultIdentity = metaplex.identity()

        let tokenAccount = PublicKey.findAssociatedTokenAccountPda(
          mint: input.mintAccount,
          owner: input.seller
        )

        let metadata = try? MetadataAccount.pda(mintKey: input.mintAccount).get()

        guard let auctionHouse = input.auctionHouse.address else {
            return nil
        }

        let escrowPaymentPda = try? Auctionhouse.buyerEscrowPda(
            auctionHouse: auctionHouse,
            buyer: input.buyer
        ).get()

        let sellerPaymentReceiptAccount = input.auctionHouse.isNative
        ? input.seller
        : PublicKey.findAssociatedTokenAccountPda(
            mint: input.auctionHouse.treasuryMint,
            owner: input.seller
        )

        let buyerReceiptTokenAccount = PublicKey.findAssociatedTokenAccountPda(
            mint: input.mintAccount,
            owner: input.buyer
        )

        let tokenSize = input.isPartialSale ? input.listing.listingReceipt.tokenSize : input.bid.bidReceipt.tokenSize
        let freeTradeStatePda = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouse,
            wallet: input.seller,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.mintAccount,
            buyerPrice: Lamports(),
            tokenSize: tokenSize,
            tokenAccount: tokenAccount
        ).get()

        let programAsSignerPda = try? Auctionhouse.programAsSignerPda().get()

        guard let tokenAccount,
              let metadata,
              let escrowPaymentPda,
              let sellerPaymentReceiptAccount,
              let buyerReceiptTokenAccount,
              let freeTradeStatePda,
              let programAsSignerPda else {
            return nil
        }

        return ExecuteSaleBuilderParameters(
            executeSaleInput: input,
            escrowPaymentPda: escrowPaymentPda,
            freeTradeStatePda: freeTradeStatePda,
            programAsSignerPda: programAsSignerPda,
            defaultIdentity: defaultIdentity,
            tokenAccount: tokenAccount,
            metadata: metadata,
            sellerPaymentReceiptAccount: sellerPaymentReceiptAccount,
            buyerReceiptTokenAccount: buyerReceiptTokenAccount,
            auctionHouse: auctionHouse
        )
    }

    private func createOperationResult(
        _ parameters: ExecuteSaleBuilderParameters,
        auctionHouse: AuctionhouseArgs
    ) -> OperationResult<Purchase, OperationError> {
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
                if let receipt = parameters.receipt {
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
                        bookkeeper: parameters.bookkeeper,
                        receipt: parameters.receipt?.publicKey,
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
