//
//  CancelBidBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/11/22.
//

import AuctionHouse
import Foundation
import Solana

extension TransactionBuilder {
    static func cancelBidBuilder(parameters: CancelBidBuilderParameters) -> TransactionBuilder {
        let accounts = CancelAccounts(
            wallet: parameters.wallet,
            tokenAccount: parameters.tokenAccount,
            tokenMint: parameters.tokenMint,
            authority: parameters.authority,
            auctionHouse: parameters.auctionHouse,
            auctionHouseFeeAccount: parameters.auctionHouseFeeAccount,
            tradeState: parameters.tradeState
        )
        let args = CancelArgs(
            buyerPrice: parameters.buyerPrice,
            tokenSize: parameters.tokenSize
        )

        var cancelBidInstruction = createCancelInstruction(
            accounts: CancelInstructionAccounts(accounts: accounts),
            args: CancelInstructionArgs(args: args)
        )
        var cancelSigners: [Account] = []

        if let auctioneerAuthoritySigner = parameters.auctioneerAuthoritySigner,
           let auctioneerPda = parameters.auctioneerPda {
            cancelBidInstruction = createAuctioneerCancelInstruction(
                accounts: AuctioneerCancelInstructionAccounts(
                    auctioneerAuthority: auctioneerAuthoritySigner.publicKey,
                    ahAuctioneerPda: auctioneerPda,
                    accounts: accounts
                ),
                args: AuctioneerCancelInstructionArgs(args: args)
            )
            cancelSigners.append(auctioneerAuthoritySigner)
        }

        let bidReceipt: (addBidReceipt: Bool, instruction: InstructionWithSigner?) = {
            guard let receipt = parameters.receipt else {
                return (false, nil)
            }

            let accounts = CancelBidReceiptInstructionAccounts(
                receipt: receipt,
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
