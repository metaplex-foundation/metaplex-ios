//
//  CancelBidBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/11/22.
//

import AuctionHouse
import Foundation
import Solana

struct CancelBidBuilderParameters {
    let wallet: PublicKey
    let tokenAccount: PublicKey
    let mint: PublicKey
    let auctionHouseAddress: PublicKey
    let auctionHouse: Auctionhouse
    let bid: Bid
    let auctioneerAuthority: Account?
}

extension TransactionBuilder {
    static func cancelBidBuilder(parameters: CancelBidBuilderParameters) -> TransactionBuilder {
        let accounts = CancelInstructionAccounts(
            wallet: parameters.wallet,
            tokenAccount: parameters.tokenAccount,
            tokenMint: parameters.mint,
            authority: parameters.auctionHouse.authority,
            auctionHouse: parameters.auctionHouseAddress,
            auctionHouseFeeAccount: parameters.auctionHouse.auctionHouseFeeAccount,
            tradeState: parameters.bid.bidReceipt.tradeState,
            tokenProgram: nil
        )
        let args = CancelInstructionArgs(
            buyerPrice: parameters.bid.bidReceipt.price,
            tokenSize: parameters.bid.bidReceipt.tokenSize
        )

        var cancelBidInstruction = createCancelInstruction(accounts: accounts, args: args)
        var cancelSigners: [Account] = []
        if let auctioneerAuthority = parameters.auctioneerAuthority,
           let auctioneerPda = try? Auctionhouse.auctioneerPda(
            auctionHouse: parameters.auctionHouseAddress,
            auctioneerAuthority: auctioneerAuthority.publicKey
           ).get() {
            let auctioneerAccounts = AuctioneerCancelInstructionAccounts(
                wallet: parameters.wallet,
                tokenAccount: parameters.tokenAccount,
                tokenMint: parameters.mint,
                authority: parameters.auctionHouse.authority,
                auctioneerAuthority: auctioneerAuthority.publicKey,
                auctionHouse: parameters.auctionHouseAddress,
                auctionHouseFeeAccount: parameters.auctionHouse.auctionHouseFeeAccount,
                tradeState: parameters.bid.bidReceipt.tradeState,
                ahAuctioneerPda: auctioneerPda,
                tokenProgram: nil
            )
            let auctioneeerArgs = AuctioneerCancelInstructionArgs(
                buyerPrice: parameters.bid.bidReceipt.price,
                tokenSize: parameters.bid.bidReceipt.tokenSize
            )
            cancelBidInstruction = createAuctioneerCancelInstruction(accounts: auctioneerAccounts, args: auctioneeerArgs)
            cancelSigners.append(auctioneerAuthority)
        }

        var bidReceiptAccounts: CancelBidReceiptInstructionAccounts?
        if case let .some(purchaseReceipt) = parameters.bid.bidReceipt.purchaseReceipt {
            bidReceiptAccounts = CancelBidReceiptInstructionAccounts(
                receipt: purchaseReceipt,
                instruction: PublicKey.sysvarInstructionsPublicKey
            )
        }

        return TransactionBuilder
            .build()
            .add(
                .init(
                    instruction: cancelBidInstruction,
                    signers: cancelSigners,
                    key: "cancelBid"
                )
            )
            .when(
                bidReceiptAccounts != nil,
                instruction: .init(
                    instruction: createCancelBidReceiptInstruction(accounts: bidReceiptAccounts!),
                    signers: [],
                    key: "cancelBidReceipt"
                )
            )
    }
}
