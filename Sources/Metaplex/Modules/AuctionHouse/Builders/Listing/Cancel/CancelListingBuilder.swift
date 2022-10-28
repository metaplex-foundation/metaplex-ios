//
//  CancelListingBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/16/22.
//

import AuctionHouse
import Foundation
import Solana

extension TransactionBuilder {
    static func cancelListingBuilder(parameters: CancelListingBuilderParameters) -> TransactionBuilder {
        // MARK: - Accounts

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
            buyerPrice: parameters.price,
            tokenSize: parameters.tokenSize
        )

        // MARK: - Cancel Instruction

        var cancelListingInstruction = createCancelInstruction(
            accounts: CancelInstructionAccounts(accounts: accounts),
            args: CancelInstructionArgs(args: args)
        )
        var cancelSigners: [Account] = []

        if let auctioneerAuthoritySigner = parameters.auctioneerAuthoritySigner,
           let auctioneerPda = parameters.auctioneerPda {
            cancelListingInstruction = createAuctioneerCancelInstruction(
                accounts: AuctioneerCancelInstructionAccounts(
                    auctioneerAuthority: auctioneerAuthoritySigner.publicKey,
                    ahAuctioneerPda: auctioneerPda,
                    accounts: accounts
                ),
                args: AuctioneerCancelInstructionArgs(args: args)
            )
            cancelSigners.append(auctioneerAuthoritySigner)
        }

        // MARK: - Receipt Instruction

        let listingReceipt: (addListingReceipt: Bool, instruction: InstructionWithSigner?) = {
            guard let receipt = parameters.receipt else {
                return (false, nil)
            }

            let accounts = CancelListingReceiptInstructionAccounts(
                receipt: receipt,
                instruction: PublicKey.sysvarInstructionsPublicKey
            )

            let instruction = InstructionWithSigner(
                instruction: createCancelListingReceiptInstruction(accounts: accounts),
                signers: [],
                key: "cancelListingReceipt"
            )

            return (true, instruction)
        }()

        // MARK: - Transaction Builder

        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(
                    instruction: cancelListingInstruction,
                    signers: cancelSigners,
                    key: "cancelListing"
                )
            )
            .when(
                listingReceipt.addListingReceipt,
                instruction: listingReceipt.instruction
            )
    }
}
