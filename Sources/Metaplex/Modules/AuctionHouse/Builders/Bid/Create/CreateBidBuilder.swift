//
//  CreateBidBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/12/22.
//

import AuctionHouse
import Foundation
import Solana

extension TransactionBuilder {
    static func createBidBuilder(parameters: CreateBidBuilderParameters) -> TransactionBuilder {
        // MARK: - Buy Instruction

        let buyAccounts = BuyAccounts(
            wallet: parameters.wallet,
            paymentAccount: parameters.paymentAccount,
            transferAuthority: parameters.transferAuthority,
            treasuryMint: parameters.treasuryMint,
            metadata: parameters.metadata,
            escrowPaymentAccount: parameters.escrowPaymentAccount,
            authority: parameters.authority,
            auctionHouse: parameters.auctionHouse,
            auctionHouseFeeAccount: parameters.auctionHouseFeeAccount,
            buyerTradeState: parameters.buyerTradeState
        )

        let buyArgs = BuyArgs(
            tradeStateBump: parameters.tradeStateBump,
            escrowPaymentBump: parameters.escrowPaymentBump,
            buyerPrice: parameters.buyerPrice,
            tokenSize: parameters.tokenSize
        )

        let buyInstruction: TransactionInstruction
        var buySigners = [parameters.buyerSigner]

        #warning("This is incorrect and does not consider auctionHouse.authority sense it is not an Account")
        if let authoritySigner = parameters.authoritySigner {
            buySigners.append(authoritySigner)
        }

        if let auctioneerAuthority = parameters.auctioneerAuthoritySigner,
           let auctioneerPda = try? Auctionhouse.auctioneerPda(
            auctionHouse: parameters.auctionHouse,
            auctioneerAuthority: auctioneerAuthority.publicKey
           ).get() {
            if let tokenAccount = parameters.tokenAccount {
                let accounts = AuctioneerBuyInstructionAccounts(
                    tokenAccount: tokenAccount,
                    auctioneerAuthority: auctioneerAuthority.publicKey,
                    ahAuctioneerPda: auctioneerPda,
                    accounts: buyAccounts
                )
                let args = AuctioneerBuyInstructionArgs(args: buyArgs)
                buyInstruction = createAuctioneerBuyInstruction(accounts: accounts, args: args)
            } else {
                let accounts = AuctioneerPublicBuyInstructionAccounts(
                    tokenAccount: parameters.buyerTokenAccount,
                    auctioneerAuthority: auctioneerAuthority.publicKey,
                    ahAuctioneerPda: auctioneerPda,
                    accounts: buyAccounts
                )
                let args = AuctioneerPublicBuyInstructionArgs(args: buyArgs)
                buyInstruction = createAuctioneerPublicBuyInstruction(accounts: accounts, args: args)
            }
            buySigners.append(auctioneerAuthority)
        } else {
            if let tokenAccount = parameters.tokenAccount {
                let accounts = BuyInstructionAccounts(
                    tokenAccount: tokenAccount,
                    accounts: buyAccounts
                )
                let args = BuyInstructionArgs(args: buyArgs)
                buyInstruction = createBuyInstruction(accounts: accounts, args: args)
            } else {
                let accounts = PublicBuyInstructionAccounts(
                    tokenAccount: parameters.buyerTokenAccount,
                    accounts: buyAccounts
                )
                let args = PublicBuyInstructionArgs(args: buyArgs)
                buyInstruction = createPublicBuyInstruction(accounts: accounts, args: args)
            }
        }

        // MARK: - Print Receipt Instruction

        let printReceipt: (shouldPrintReceipt: Bool, instruction: InstructionWithSigner?) = {
            guard let receipt = parameters.receipt else {
                return (false, nil)
            }

            let printReceiptAccounts = PrintBidReceiptInstructionAccounts(
                receipt: receipt.publicKey,
                bookkeeper: parameters.bookkeeper,
                instruction: PublicKey.sysvarInstructionsPublicKey
            )
            let printReceiptArgs = PrintBidReceiptInstructionArgs(receiptBump: receipt.bump)

            let shouldPrintReciept = parameters.shouldPrintReceipt && parameters.auctioneerAuthoritySigner == nil
            let instruction = InstructionWithSigner(
                instruction: createPrintBidReceiptInstruction(
                    accounts: printReceiptAccounts,
                    args: printReceiptArgs
                ),
                signers: [parameters.bookkeeperSigner],
                key: "printBidReceipt"
            )

            return (shouldPrintReciept, instruction)
        }()

        // MARK: - Create Token Account Instruction

        // TODO: Create an account if it doesn't exist. Will come back to this as there's a bit involved.

        // MARK: - Transaction Builder

        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(
                    instruction: buyInstruction,
                    signers: buySigners,
                    key: "buy"
                )
            )
            .when(
                printReceipt.shouldPrintReceipt,
                instruction: printReceipt.instruction
            )
    }
}
