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
        let accounts = CancelAccounts(
            wallet: parameters.wallet,
            tokenAccount: parameters.tokenAccount,
            tokenMint: parameters.mint,
            authority: parameters.auctionHouse.authority,
            auctionHouse: parameters.auctionHouseAddress,
            auctionHouseFeeAccount: parameters.auctionHouse.auctionHouseFeeAccount,
            tradeState: parameters.bid.bidReceipt.tradeState.publicKey
        )
        let args = CancelArgs(
            buyerPrice: parameters.bid.bidReceipt.price,
            tokenSize: parameters.bid.bidReceipt.tokenSize
        )

        var cancelBidInstruction = createCancelInstruction(
            accounts: CancelInstructionAccounts(accounts: accounts),
            args: CancelInstructionArgs(args: args)
        )
        var cancelSigners: [Account] = []

        if let auctioneerAuthority = parameters.auctioneerAuthority,
           let auctioneerPda = try? Auctionhouse.auctioneerPda(
            auctionHouse: parameters.auctionHouseAddress,
            auctioneerAuthority: auctioneerAuthority.publicKey
           ).get() {
            cancelBidInstruction = createAuctioneerCancelInstruction(
                accounts: AuctioneerCancelInstructionAccounts(
                    auctioneerAuthority: auctioneerAuthority.publicKey,
                    ahAuctioneerPda: auctioneerPda,
                    accounts: accounts
                ),
                args: AuctioneerCancelInstructionArgs(args: args)
            )
            cancelSigners.append(auctioneerAuthority)
        }

        let bidReceipt: (addBidReceipt: Bool, instruction: InstructionWithSigner?) = {
            guard let purchaseReceipt = parameters.bid.bidReceipt.purchaseReceipt else {
                return (false, nil)
            }

            let accounts = CancelBidReceiptInstructionAccounts(
                receipt: purchaseReceipt,
                instruction: PublicKey.sysvarInstructionsPublicKey
            )

            let instruction = InstructionWithSigner(
                instruction: createCancelBidReceiptInstruction(accounts: accounts),
                signers: [],
                key: "cancelBidReceipt"
            )

            return (true, instruction)
        }()

        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(
                    instruction: cancelBidInstruction,
                    signers: cancelSigners,
                    key: "cancelBid"
                )
            )
            .when(
                bidReceipt.addBidReceipt,
                instruction: bidReceipt.instruction
            )
    }
}
