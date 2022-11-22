//
//  CreateTokenBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/7/22.
//

import Foundation
import Solana

extension TransactionBuilder {
    static func createTokenBuilder(parameters: CreateTokenBuilderParameters) -> TransactionBuilder {
        if let accountSigner = parameters.newAccountSigner {
            // MARK: - Initialize Instruction
            
            let initializeInstruction = SolanaTokenProgram.initializeAccountInstruction(
                programId: parameters.programId,
                account: accountSigner.publicKey,
                mint: parameters.mint,
                owner: parameters.owner
            )
            
            // MARK: - Transaction Builder
            
            return TransactionBuilder
                .createAccountBuilder(
                    parameters: parameters.createAccountParameters
                )
                .add(
                    InstructionWithSigner(
                        instruction: initializeInstruction,
                        signers: [accountSigner],
                        key: "initializeToken"
                    )
                )
        }
        
        // MARK: - Associated Instruction
        
        let accosicatedInstruction = AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
            associatedProgramId: parameters.associatedProgramId,
            programId: parameters.programId,
            mint: parameters.mint,
            associatedAccount: parameters.associatedAccount,
            owner: parameters.owner,
            payer: parameters.payer
        )
        
        // MARK: - Transaction Builder
        
        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(
                    instruction: accosicatedInstruction,
                    signers: [parameters.payerSigner],
                    key: "createAssociatedTokenAccount"
                )
            )
    }
}
