//
//  CreateBidOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/12/22.
//

import AuctionHouse
import Foundation
import Solana

typealias CreateBidOperation = OperationResult<CreateBidInput, OperationError>

class CreateBidOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = CreateBidInput
    typealias O = Bid

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: CreateBidOperation) -> OperationResult<Bid, OperationError> {
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
        _ input: CreateBidInput
    ) -> Result<CreateBidBuilderParameters, OperationError> {
        let defaultIdentity = metaplex.identity()
        let buyer = input.buyer ?? defaultIdentity

        guard let auctionHouseAddress = input.auctionHouse.address else {
            return .failure(.couldNotFindAuctionHouse)
        }

        guard let escrowPaymentAccount = try? Auctionhouse.buyerEscrowPda(
            auctionHouse: auctionHouseAddress,
            buyer: buyer.publicKey
        ).get()
        else { return .failure(.couldNotFindEscrowPaymentAccount) }

        guard let paymentAccount = input.auctionHouse.isNative
        ? buyer.publicKey
        : PublicKey.findAssociatedTokenAccountPda(
            mint: input.auctionHouse.treasuryMint,
            owner: buyer.publicKey
        )
        else { return .failure(.couldNotFindPaymentAccount) }

        guard let metadata = try? MetadataAccount.pda(mintKey: input.mintAccount).get()
        else { return .failure(.couldNotFindMetadata) }

        let buyerPrice = input.price ?? 0
        let tokenSize = input.tokens ?? 1

        guard let buyerTradeState = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouseAddress,
            wallet: buyer.publicKey,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.mintAccount,
            buyerPrice: buyerPrice,
            tokenSize: tokenSize,
            tokenAccount: input.tokenAccount
        ).get()
        else { return .failure(.couldNotFindBuyerTradeStatePda) }

        guard let buyerTokenAccount = PublicKey.findAssociatedTokenAccountPda(
            mint: input.mintAccount,
            owner: buyer.publicKey
        )
        else { return .failure(.couldNotFindBuyerTokenAccount) }

        let parameters = CreateBidBuilderParameters(
            createBidInput: input,
            escrowPaymentPda: escrowPaymentAccount,
            buyerTradePda: buyerTradeState,
            defaultIdentity: defaultIdentity,
            paymentAccount: paymentAccount,
            metadata: metadata,
            auctionHouse: auctionHouseAddress,
            buyerTokenAccount: buyerTokenAccount
        )
        return .success(parameters)
    }

    private func createOperationResult(
        _ parameters: CreateBidBuilderParameters,
        auctionHouse: AuctionhouseArgs
    ) -> OperationResult<Bid, OperationError> {
        let createBidBuilder = TransactionBuilder.createBidBuilder(parameters: parameters)
        let operation = OperationResult<SignatureStatus, OperationError>.init { callback in
            createBidBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
                switch result {
                case .success(let status):
                    callback(.success(status))
                case .failure(let error):
                    callback(.failure(.confirmTransactionError(error)))
                }
            }
        }.flatMap { status in
            OperationResult<Bid, OperationError>.init { callback in
                if let receipt = parameters.receipt {
                    self.metaplex.auctionHouse.findBidByReceipt(
                        receipt.publicKey,
                        auctionHouse: auctionHouse
                    ) { callback($0) }
                } else {
                    let bid = LazyBid(
                        auctionHouse: auctionHouse,
                        tradeState: Pda(publicKey: parameters.buyerTradeState, bump: parameters.tradeStateBump),
                        bookkeeper: parameters.bookkeeper,
                        buyer: parameters.buyer,
                        metadata: parameters.metadata,
                        tokenAddress: parameters.tokenAccount,
                        receipt: parameters.receipt,
                        purchaseReceipt: nil,
                        price: parameters.buyerPrice,
                        tokenSize: parameters.tokenSize,
                        createdAt: Int64(Date().timeIntervalSinceNow),
                        canceledAt: nil
                    )
                    self.metaplex.auctionHouse.loadBid(bid) { callback($0) }
                }
            }
        }
        return operation
    }
}
