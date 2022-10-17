//
//  CreateBidOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/12/22.
//

import AuctionHouse
import Foundation
import Solana

public struct CreateBidInput {
    let auctionHouse: Auctionhouse
    let buyer: Account?
    let authority: Account?
    let auctioneerAuthority: Account?
    let mintAccount: PublicKey
    let seller: PublicKey?
    let tokenAccount: PublicKey?
    let price: UInt64?
    let tokens: UInt64?
    let printReceipt: Bool
    let bookkeeper: Account?
}

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
            guard let parameters = self.createParametersFromInput(input) else { return .failure(.couldNotFindPDA) } // TODO: Fix error here, maybe throw from `createParametersFromInput(_:)`
            return self.createOperationResult(parameters)
        }
    }

    private func createParametersFromInput(_ input: CreateBidInput) -> CreateBidBuilderParameters? {
        let buyer = input.buyer ?? self.metaplex.identity()

        let paymentAccount = input.auctionHouse.isNative
        ? input.buyer?.publicKey
        : PublicKey.findAssociatedTokenAccountPda(
            mint: input.auctionHouse.treasuryMint,
            owner: buyer.publicKey
        )

        let metadata = try? MetadataAccount.pda(mintKey: input.mintAccount).get()

        guard let auctionHouseAddress = input.auctionHouse.address else {
            return nil //.failure(.couldNotFindPDA)
        }

        let escrowPaymentAccount = try? Auctionhouse.buyerEscrowPda(
            auctionHouse: auctionHouseAddress,
            buyer: buyer.publicKey
        ).get()


        let buyerPrice = input.price ?? 0
        let tokenSize = input.tokens ?? 1

        let buyerTradeState = try? Auctionhouse.tradeStatePda(
            auctionHouse: auctionHouseAddress,
            wallet: buyer.publicKey,
            treasuryMint: input.auctionHouse.treasuryMint,
            mintAccount: input.mintAccount,
            buyerPrice: buyerPrice,
            tokenSize: tokenSize,
            tokenAccount: input.tokenAccount
        ).get()

        let buyerTokenAccount = PublicKey.findAssociatedTokenAccountPda(
            mint: input.mintAccount,
            owner: buyer.publicKey
        )

        let tokenAccountPda: (PublicKey?) -> PublicKey? = { seller in
            if let seller {
                return PublicKey.findAssociatedTokenAccountPda(mint: input.mintAccount, owner: seller)
            }
            return nil
        }
        let tokenAccount = input.tokenAccount ?? tokenAccountPda(input.seller)

        let bookkeeper = input.bookkeeper ?? self.metaplex.identity()

        guard let buyerTradeState else { return nil /*.failure(.couldNotFindPDA)*/ }
        let receipt = input.printReceipt ? try? Bidreceipt.pda(tradeStateAddress: buyerTradeState.publicKey).get() : nil

        guard let paymentAccount,
              let metadata,
              let escrowPaymentAccount,
              let buyerTokenAccount else {
            return nil //.failure(.couldNotFindPDA)
        }

        return CreateBidBuilderParameters(
            authority: input.authority,
            buyerPrice: buyerPrice,
            tokenSize: tokenSize,
            paymentAccount: paymentAccount,
            metadata: metadata,
            escrowPaymentAccount: escrowPaymentAccount,
            buyerTradeState: buyerTradeState,
            buyerTokenAccount: buyerTokenAccount,
            auctioneerAuthority: input.auctioneerAuthority,
            tokenAccount: tokenAccount,
            mintAccount: input.mintAccount,
            seller: input.seller,
            buyer: buyer,
            auctionHouse: input.auctionHouse,
            auctionHouseAddress: auctionHouseAddress,
            bookkeeper: bookkeeper,
            printReceipt: (input.printReceipt, receipt)
        )
    }

    private func createOperationResult(_ parameters: CreateBidBuilderParameters) -> OperationResult<Bid, OperationError> {
        let createBidBuilder = TransactionBuilder.createBidBuilder(parameters: parameters)
        let operation: OperationResult<Bid, OperationError> = OperationResult<SignatureStatus, OperationError>.init { callback in
            createBidBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
                switch result {
                case .success(let status):
                    guard let status else {
                        callback(.failure(.nilSignatureStatus))
                        return
                    }
                    callback(.success(status))
                case .failure(let error):
                    callback(.failure(.confirmTransactionError(error)))
                }
            }
        }.flatMap { status in
            OperationResult<Bid, OperationError>.init { callback in
                if let receipt = parameters.printReceipt.receipt {
                    self.metaplex.auctionHouse.findBidByReceipt(
                        receipt.publicKey,
                        auctionHouse: parameters.auctionHouse
                    ) { callback($0) }
                } else {
                    let bid = LazyBid(
                        auctionHouse: parameters.auctionHouse,
                        tradeState: parameters.buyerTradeState,
                        bookkeeper: parameters.bookkeeper.publicKey,
                        buyer: parameters.buyer.publicKey,
                        metadata: parameters.metadata,
                        tokenAddress: parameters.tokenAccount,
                        receipt: parameters.printReceipt.receipt,
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
