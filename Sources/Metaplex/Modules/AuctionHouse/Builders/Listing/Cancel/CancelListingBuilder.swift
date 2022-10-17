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
        let accounts = CancelAccounts(
            wallet: parameters.wallet,
            tokenAccount: parameters.tokenAccount,
            tokenMint: parameters.tokenMint,
            authority: parameters.authority,
            auctionHouse: parameters.auctionHouseAddress,
            auctionHouseFeeAccount: parameters.auctionHouseFeeAccount,
            tradeState: parameters.tradeState
        )
        let args = CancelArgs(
            buyerPrice: parameters.price,
            tokenSize: parameters.tokenSize
        )

        var cancelBidInstruction = createCancelInstruction(
            accounts: CancelInstructionAccounts(accounts: accounts),
            args: CancelInstructionArgs(args: args)
        )
        var cancelSigners: [Account] = []

        if let auctioneerAuthority = parameters.auctioneerAuthority,
           let auctioneerPda = parameters.auctioneerPda {
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

        let listingReceipt: (addListingReceipt: Bool, instruction: InstructionWithSigner?) = {
            guard let purchaseReceipt = parameters.purchaseReceipt else {
                return (false, nil)
            }

            let accounts = CancelListingReceiptInstructionAccounts(
                receipt: purchaseReceipt,
                instruction: PublicKey.sysvarInstructionsPublicKey
            )

            let instruction = InstructionWithSigner(
                instruction: createCancelListingReceiptInstruction(accounts: accounts),
                signers: [],
                key: "cancelListingReceipt"
            )

            return (true, instruction)
        }()

        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(
                    instruction: cancelBidInstruction,
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
