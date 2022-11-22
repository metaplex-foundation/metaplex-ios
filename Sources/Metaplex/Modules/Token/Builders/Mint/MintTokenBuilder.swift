//
//  MintTokenBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/7/22.
//

import Foundation
import Solana

extension TransactionBuilder {
    static func mintTokenBuilder(parameters: MintTokenBuilderParameters) -> TransactionBuilder {
        // MARK: - Mint Instruction

        let mintInstruction = SolanaTokenProgram.mintToInstruction(
            tokenProgramId: parameters.tokenProgramId,
            mint: parameters.mint,
            destination: parameters.destination,
            authority: parameters.authority,
            amount: parameters.amount
        )

        // MARK: - Transaction Builder

        return TransactionBuilder
            .build()
            .add(
                InstructionWithSigner(
                    instruction: mintInstruction,
                    signers: [parameters.mintAuthority],
                    key: "mintTokens"
                )
            )
    }
}
