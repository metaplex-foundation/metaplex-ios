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
    let auctionHouse: AuctionhouseArgs
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

    init(
        auctionHouse: AuctionhouseArgs,
        buyer: Account? = nil,
        authority: Account? = nil,
        auctioneerAuthority: Account? = nil,
        mintAccount: PublicKey,
        seller: PublicKey? = nil,
        tokenAccount: PublicKey? = nil,
        price: UInt64? = 0,
        tokens: UInt64? = 1,
        printReceipt: Bool = true,
        bookkeeper: Account? = nil
    ) {
        self.auctionHouse = auctionHouse
        self.buyer = buyer
        self.authority = authority
        self.auctioneerAuthority = auctioneerAuthority
        self.mintAccount = mintAccount
        self.seller = seller
        self.tokenAccount = tokenAccount
        self.price = price
        self.tokens = tokens
        self.printReceipt = printReceipt
        self.bookkeeper = bookkeeper
    }
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
            return self.createOperationResult(parameters, auctionHouse: input.auctionHouse)
        }
    }

    private func createParametersFromInput(_ input: CreateBidInput) -> CreateBidBuilderParameters? {
        let defaultIdentity = metaplex.identity()
        let buyer = input.buyer ?? defaultIdentity

        guard let auctionHouseAddress = input.auctionHouse.address else {
            return nil //.failure(.couldNotFindPDA)
        }

        let escrowPaymentAccount = try? Auctionhouse.buyerEscrowPda(
            auctionHouse: auctionHouseAddress,
            buyer: buyer.publicKey
        ).get()

        let paymentAccount = input.auctionHouse.isNative
        ? buyer.publicKey
        : PublicKey.findAssociatedTokenAccountPda(
            mint: input.auctionHouse.treasuryMint,
            owner: buyer.publicKey
        )

        let metadata = try? MetadataAccount.pda(mintKey: input.mintAccount).get()

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

        guard let buyerTradeState else { return nil /*.failure(.couldNotFindPDA)*/ }
        let printReceipt = input.printReceipt ? try? Bidreceipt.pda(tradeStateAddress: buyerTradeState.publicKey).get() : nil

        guard let escrowPaymentAccount,
              let paymentAccount,
              let metadata,
              let buyerTokenAccount else {
            return nil //.failure(.couldNotFindPDA)
        }

        return CreateBidBuilderParameters(
            createBidInput: input,
            escrowPaymentPda: escrowPaymentAccount,
            buyerTradePda: buyerTradeState,
            printReceipt: printReceipt,
            defaultIdentity: defaultIdentity,
            paymentAccount: paymentAccount,
            metadata: metadata,
            auctionHouse: auctionHouseAddress,
            buyerTokenAccount: buyerTokenAccount
        )
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
