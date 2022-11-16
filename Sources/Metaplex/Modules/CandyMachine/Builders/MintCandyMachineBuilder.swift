//
//  MintCandyMachineBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/3/22.
//

import CandyMachine
import Foundation
import Solana

extension TransactionBuilder {
    static func mintCandyMachineBuilder(parameters: MintCandyMachineBuilderParameters) -> TransactionBuilder {
        // MARK: - Accounts

        let mintAccounts = MintNftInstructionAccounts(
            candyMachine: parameters.candyMachine,
            candyMachineCreator: parameters.candyMachineCreator,
            payer: parameters.payer,
            wallet: parameters.wallet,
            metadata: parameters.metadata,
            mint: parameters.mint,
            mintAuthority: parameters.mintAuthority,
            updateAuthority: parameters.updateAuthority,
            masterEdition: parameters.masterEdition,
            tokenMetadataProgram: parameters.tokenMetadataProgram,
            clock: parameters.clock,
            recentBlockhashes: parameters.recentBlockhashes,
            instructionSysvarAccount: parameters.instructionSysvarAccount
        )

        let mintArgs = MintNftInstructionArgs(creatorBump: parameters.creatorBump)

        // MARK: - Create Token with Mint

        let tokenWithMintBuilder = TransactionBuilder.createTokenWithMintBuilder(parameters: parameters.createTokenWithMintParameters)

        // MARK: - Mint NFT Instruction

        let mintNftInstruction = createMintNftInstruction(accounts: mintAccounts, args: mintArgs)

        if let tokenMint = parameters.tokenMint {
            
        }

        // MARK: - Transaction Builder

        let tx = TransactionBuilder
            .build()
            .add(tokenWithMintBuilder)
            .add(
                InstructionWithSigner(
                    instruction: mintNftInstruction,
                    signers: [parameters.payerSigner, parameters.mintSigner],
                    key: "mintNft"
                )
            )

        return tx
    }
}
