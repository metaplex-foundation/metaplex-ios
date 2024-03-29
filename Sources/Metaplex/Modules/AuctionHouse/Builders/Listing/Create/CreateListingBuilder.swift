//
//  CreateListingBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation
import Solana

extension TransactionBuilder {
    static func createListingBuilder(parameters: CreateListingBuilderParameters) -> TransactionBuilder {
        // MARK: - Accounts

        let sellAccounts = SellAccounts(
            wallet: parameters.wallet,
            tokenAccount: parameters.tokenAccount,
            metadata: parameters.metadata,
            authority: parameters.authority,
            auctionHouse: parameters.auctionHouse,
            auctionHouseFeeAccount: parameters.auctionHouseFeeAccount,
            sellerTradeState: parameters.sellerTradeState,
            freeSellerTradeState: parameters.freeSellerTradeState,
            programAsSigner: parameters.programAsSigner
        )

        let sellArgs = SellArgs(
            tradeStateBump: parameters.tradeStateBump,
            freeTradeStateBump: parameters.freeTradeStateBump,
            programAsSignerBump: parameters.programAsSignerBump,
            tokenSize: parameters.tokenSize
        )

        // MARK: - Sell Instruction

        var sellInstruction = createSellInstruction(
            accounts: SellInstructionAccounts(accounts: sellAccounts),
            args: SellInstructionArgs(buyerPrice: parameters.buyerPrice, args: sellArgs)
        )
        var sellSigners = [parameters.sellerSigner]

        if let auctioneerAuthoritySigner = parameters.auctioneerAuthoritySigner,
           let auctioneerPda = parameters.auctioneerPda {
            sellInstruction = createAuctioneerSellInstruction(
                accounts: AuctioneerSellInstructionAccounts(
                    auctioneerAuthority: auctioneerAuthoritySigner.publicKey,
                    auctioneerPda: auctioneerPda,
                    accounts: sellAccounts
                ),
                args: AuctioneerSellInstructionArgs(args: sellArgs)
            )
            sellSigners.append(auctioneerAuthoritySigner)
        }

        // MARK: - Receipt Instruction

        let printReceipt: (shouldPrintReceipt: Bool, instruction: InstructionWithSigner?) = {
            guard let receipt = parameters.receipt else {
                return (false, nil)
            }

            let printReceiptAccounts = PrintListingReceiptInstructionAccounts(
                receipt: receipt.publicKey,
                bookkeeper: parameters.bookkeeper,
                instruction: PublicKey.sysvarInstructionsPublicKey
            )
            let printReceiptArgs = PrintListingReceiptInstructionArgs(receiptBump: receipt.bump)

            let shouldPrintReciept = parameters.shouldPrintReceipt && parameters.auctioneerAuthoritySigner == nil
            let instruction = InstructionWithSigner(
                instruction: createPrintListingReceiptInstruction(
                    accounts: printReceiptAccounts,
                    args: printReceiptArgs
                ),
                signers: [parameters.bookkeeperSigner],
                key: "printListingReceipt"
            )

            return (shouldPrintReciept, instruction)
        }()

        // MARK: - Transaction Builder

        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(
                    instruction: sellInstruction,
                    signers: sellSigners,
                    key: "sell"
                )
            )
            .when(
                printReceipt.shouldPrintReceipt,
                instruction: printReceipt.instruction
            )
    }
}
