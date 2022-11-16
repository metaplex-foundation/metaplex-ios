//
//  CreateAccountBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/7/22.
//

import Foundation
import Solana

extension TransactionBuilder {
    static func createAccountBuilder(parameters: CreateAccountBuilderParameters) -> TransactionBuilder {
        // MARK: - Create Instruction

        let createInstruction = SystemProgram.createAccountInstruction(
            from: parameters.payer,
            toNewPubkey: parameters.newAccount,
            lamports: parameters.lamports,
            space: parameters.space,
            programPubkey: parameters.program
        )

        // MARK: - Transaction Builder

        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(
                    instruction: createInstruction,
                    signers: [parameters.payerSigner, parameters.newAccountSigner],
                    key: "createAccount"
                )
            )
    }
}
