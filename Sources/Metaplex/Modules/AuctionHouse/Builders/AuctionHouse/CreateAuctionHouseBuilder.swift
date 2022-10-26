//
//  CreateAuctionHouseBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/21/22.
//

import AuctionHouse
import Foundation
import Solana

extension TransactionBuilder {
    static func createAuctionHouseBuilder(parameters: CreateAuctionHouseBuilderParameters) -> TransactionBuilder {
        // MARK: - Accounts

        let createAccounts = CreateAuctionHouseInstructionAccounts(
            treasuryMint: parameters.treasuryMint,
            payer: parameters.payer,
            authority: parameters.authority,
            feeWithdrawalDestination: parameters.feeWithdrawalDestination,
            treasuryWithdrawalDestination: parameters.treasuryWithdrawalDestination,
            treasuryWithdrawalDestinationOwner: parameters.treasuryWithdrawalDestinationOwner,
            auctionHouse: parameters.auctionHouse,
            auctionHouseFeeAccount: parameters.auctionHouseFeeAccount,
            auctionHouseTreasury: parameters.auctionHouseTreasury
        )

        let createArgs = CreateAuctionHouseInstructionArgs(
            bump: parameters.bump,
            feePayerBump: parameters.feePayerBump,
            treasuryBump: parameters.treasuryBump,
            sellerFeeBasisPoints: parameters.sellerFeeBasisPoints,
            requiresSignOff: parameters.requiresSignOff,
            canChangeSalePrice: parameters.canChangeSalePrice
        )

        // MARK: - Auction House Instruction

        let createInstruction = createCreateAuctionHouseInstruction(accounts: createAccounts, args: createArgs)
        let createSigners = [parameters.payerSigner]

        // MARK: - Auctioneer Delegate Instruction

        let auctioneerDelegate: (shouldAddInstruction: Bool, instruction: InstructionWithSigner?) = {
            guard let auctioneerAuthority = parameters.auctioneerAuthority,
                  let auctioneerPda = parameters.auctioneerPda else {
                return (false, nil)
            }

            let auctioneerAccounts = DelegateAuctioneerInstructionAccounts(
                auctionHouse: parameters.auctionHouse,
                authority: parameters.authority,
                auctioneerAuthority: auctioneerAuthority,
                ahAuctioneerPda: auctioneerPda
            )

            let auctioneerArgs = DelegateAuctioneerInstructionArgs(scopes: parameters.auctioneerScopes)

            let auctioneerInstruction = InstructionWithSigner(
                instruction: createDelegateAuctioneerInstruction(
                    accounts: auctioneerAccounts,
                    args: auctioneerArgs
                ),
                signers: [parameters.authoritySigner],
                key: "delegateAuctioneer"
            )

            return (true, auctioneerInstruction)
        }()

        // MARK: - Transaction Builder

        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(instruction: createInstruction, signers: createSigners, key: "createAuctionHouse")
            )
            .when(auctioneerDelegate.shouldAddInstruction, instruction: auctioneerDelegate.instruction)
    }
}
