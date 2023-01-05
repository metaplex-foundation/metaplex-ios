//
//  CreateMintBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/7/22.
//

import Foundation
import Solana

extension TransactionBuilder {
    static func createMintBuilder(parameters: CreateMintBuilderParameters) -> TransactionBuilder {
        // MARK: - Mint Instruction

        let mintInstruction = SolanaTokenProgram.initializeMintInstruction(
            tokenProgramId: parameters.tokenProgramId,
            mint: parameters.mint,
            decimals: parameters.decimals,
            authority: parameters.authority,
            freezeAuthority: parameters.freezeAuthority
        )

        // MARK: - Transaction Builder

        return TransactionBuilder
            .createAccountBuilder(parameters: parameters.createAccountParameters)
            .add(
                InstructionWithSigner(
                    instruction: mintInstruction,
                    signers: [parameters.mintSigner],
                    key: "initializeMint"
                )
            )
    }
}
