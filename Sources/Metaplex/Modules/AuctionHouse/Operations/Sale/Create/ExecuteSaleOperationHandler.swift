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
        _ input: ExecuteSaleInput
    ) -> Result<ExecuteSaleBuilderParameters, OperationError> {
        let defaultIdentity = metaplex.identity()

        guard let tokenAccount = PublicKey.findAssociatedTokenAccountPda(
          mint: input.mintAccount,
          owner: input.seller
        )
        else { return .failure(.couldNotFindTokenAccount) }

        guard let metadata = try? MetadataAccount.pda(mintKey: input.mintAccount).get()
        else { return .failure(.couldNotFindMetadata) }

        guard let auctionHouse = input.auctionHouse.address else {
            return .failure(.couldNotFindAuctionHouse)
        }

        guard let escrowPaymentPda = try? Auctionhouse.buyerEscrowPda(
            auctionHouse: auctionHouse,
            buyer: input.buyer
        ).get()
        else { return .failure(.couldNotFindEscrowPaymentAccount) }

        guard let sellerPaymentReceiptAccount = input.auctionHouse.isNative
        ? input.seller
        : PublicKey.findAssociatedTokenAccountPda(
            mint: input.auctionHouse.treasuryMint,
            owner: input.seller
        )
        else { return .failure(.couldNotFindSellerReceiptAccount) }

        guard let buyerReceiptTokenAccount = PublicKey.findAssociatedTokenAccountPda(
            mint: input.mintAccount,
            owner: input.buyer
        )
        else { return .failure(.couldNotFindBuyerReceiptAccount) }

        let tokenSize = input.isPartialSale ? input.listing.listingReceipt.tokenSize : input.bid.bidReceipt.tokenSize

        guard let freeTradeStatePda = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouse,
            wallet: input.seller,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.mintAccount,
            buyerPrice: Lamports(),
            tokenSize: tokenSize,
            tokenAccount: tokenAccount
        ).get()
        else { return .failure(.couldNotFindFreeTradeStatePda) }

        guard let programAsSignerPda = try? Auctionhouse.programAsSignerPda().get()
        else { return .failure(.couldNotFindProgramAsSignerPda) }

        let parameters = ExecuteSaleBuilderParameters(
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
        return .success(parameters)
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
