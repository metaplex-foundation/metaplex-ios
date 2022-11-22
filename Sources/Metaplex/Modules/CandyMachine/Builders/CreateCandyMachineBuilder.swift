//
//  CreateCandyMachineBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/3/22.
//

import CandyMachine
import Foundation
import Solana

extension TransactionBuilder {
    static func createCandyMachineBuilder(parameters: CreateCandyMachineBuilderParameters) -> TransactionBuilder {
        // MARK: - Accounts

        let createAccounts = InitializeCandyMachineInstructionAccounts(
            candyMachine: parameters.candyMachine,
            wallet: parameters.wallet,
            authority: parameters.authority,
            payer: parameters.payer
        )

        let createArgs = InitializeCandyMachineInstructionArgs(data: parameters.data)

        // MARK: - Candy Machine Instruction

        var createInstruction = createInitializeCandyMachineInstruction(accounts: createAccounts, args: createArgs)

        if let tokenMint = parameters.tokenMint {
            createInstruction.append(
                AccountMeta(publicKey: tokenMint, isSigner: false, isWritable: false)
            )
        }

        // MARK: - System Account Instruction

        let accountInstruction = SystemProgram.createAccountInstruction(
            from: parameters.payer,
            toNewPubkey: parameters.candyMachine,
            lamports: parameters.lamports,
            space: parameters.space,
            programPubkey: parameters.programPubkey
        )

        // MARK: - Collection Instruction

        let collectionInstruction: (shouldAddInstruction: Bool, instruction: InstructionWithSigner?) = {
            guard let collectionMint = parameters.collection,
                  let metadata =  try? MetadataAccount.pda(mintKey: collectionMint).get(),
                  let masterEdition = try? MasterEditionAccount.pda(mintKey: collectionMint).get(),
                  let collectionPda = try? Candymachine.collectionPda(candyMachine: parameters.candyMachine).get().publicKey,
                  let collectionAuthority = try? MetadataAccount.collectionAuthorityPda(
                    mintKey: collectionMint,
                    collectionAuthority: collectionPda
                  ).get()
            else { return (false, nil) }

            let accounts = SetCollectionInstructionAccounts(
                candyMachine: parameters.candyMachine,
                authority: parameters.authority,
                collectionPda: collectionPda,
                payer: parameters.payer,
                metadata: metadata,
                mint: collectionMint,
                edition: masterEdition,
                collectionAuthorityRecord: collectionAuthority,
                tokenMetadataProgram: TokenMetadataProgram.publicKey
            )
            let instruction = createSetCollectionInstruction(accounts: accounts)
            let instructionWithSigner = InstructionWithSigner(
                instruction: instruction,
                signers: [parameters.authoritySigner],
                key: "setCollection"
            )
            return (true, instructionWithSigner)
        }()

        // MARK: - Transaction Builder

        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(
                    instruction: accountInstruction,
                    signers: [parameters.payerSigner, parameters.candyMachineSigner],
                    key: "createAccount"
                )
            )
            .add(
                InstructionWithSigner(
                    instruction: createInstruction,
                    signers: [parameters.payerSigner, parameters.candyMachineSigner],
                    key: "initializeCandyMachine"
                )
            )
            .when(collectionInstruction.shouldAddInstruction, instruction: collectionInstruction.instruction)
    }
}
