//
//  CreateBidBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/12/22.
//

import AuctionHouse
import Foundation
import Solana

struct CreateBidBuilderParameters {
    let authority: Account?
    let buyerPrice: UInt64
    let tokenSize: UInt64
    let paymentAccount: PublicKey
    let metadata: PublicKey
    let escrowPaymentAccount: Pda
    let buyerTradeState: Pda
    let buyerTokenAccount: PublicKey
    let auctioneerAuthority: Account?
    let tokenAccount: PublicKey?
    let mintAccount: PublicKey
    let seller: PublicKey?
    let buyer: Account
    let auctionHouse: Auctionhouse
    let auctionHouseAddress: PublicKey
    let bookkeeper: Account
    let printReceipt: (shouldPrintReceipt: Bool, receipt: Pda?)
}

extension TransactionBuilder {
    static func createBidBuilder(parameters: CreateBidBuilderParameters) -> TransactionBuilder {
        let authority = parameters.authority?.publicKey ?? parameters.auctionHouse.authority

        // MARK: - Buy Instruction

        let buyAccounts = BuyAccounts(
            wallet: parameters.buyer.publicKey,
            paymentAccount: parameters.paymentAccount,
            transferAuthority: parameters.buyer.publicKey,
            treasuryMint: parameters.auctionHouse.treasuryMint,
            metadata: parameters.metadata,
            escrowPaymentAccount: parameters.escrowPaymentAccount.publicKey,
            authority: authority,
            auctionHouse: parameters.auctionHouseAddress,
            auctionHouseFeeAccount: parameters.auctionHouse.auctionHouseFeeAccount,
            buyerTradeState: parameters.buyerTradeState.publicKey
        )

        let buyArgs = BuyArgs(
            tradeStateBump: parameters.buyerTradeState.bump,
            escrowPaymentBump: parameters.escrowPaymentAccount.bump,
            buyerPrice: parameters.buyerPrice,
            tokenSize: parameters.tokenSize
        )

        let buyInstruction: TransactionInstruction
        var buySigners = [parameters.buyer]
        #warning("This is incorrect and does not consider auctionHouse.authority sense it is not an Account")
        if let authority = parameters.authority {
            buySigners.append(authority)
        }

        if let auctioneerAuthority = parameters.auctioneerAuthority,
           let auctioneerPda = try? Auctionhouse.auctioneerPda(
            auctionHouse: parameters.auctionHouseAddress,
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
            guard let receipt = parameters.printReceipt.receipt else {
                return (false, nil)
            }

            let printReceiptAccounts = PrintBidReceiptInstructionAccounts(
                receipt: receipt.publicKey,
                bookkeeper: parameters.bookkeeper.publicKey,
                instruction: PublicKey.sysvarInstructionsPublicKey
            )
            let printReceiptArgs = PrintBidReceiptInstructionArgs(receiptBump: receipt.bump)

            let shouldPrintReciept = parameters.printReceipt.shouldPrintReceipt && parameters.auctioneerAuthority != nil
            let instruction = InstructionWithSigner(
                instruction: createPrintBidReceiptInstruction(
                    accounts: printReceiptAccounts,
                    args: printReceiptArgs
                ),
                signers: [parameters.bookkeeper],
                key: "printBidReceipt"
            )

            return (shouldPrintReciept, instruction)
        }()

        // MARK: - Create Token Account Instruction

        // TODO: Create an account if it doesn't exist. Will come back to this as there's a bit involved.
        // I'm also not positive we can ever get to a state where create account is needed because there are several pieces that rely on tokenAccount existing otherwise it all fails
        // Need to do more research.

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
