//
//  CreateTokenWithMintBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/7/22.
//

import Foundation

extension TransactionBuilder {
    static func createTokenWithMintBuilder(parameters: CreateTokenWithMintBuilderParameters) -> TransactionBuilder {
        // MARK: - Builders

        let createMintBuilder = TransactionBuilder.createMintBuilder(parameters: parameters.createMintParameters)
        let createTokenBuilder = TransactionBuilder.createTokenBuilder(parameters: parameters.createTokenParameters)
        let mintTokenBuilder = TransactionBuilder.mintTokenBuilder(parameters: parameters.mintTokenParameters)

        return TransactionBuilder
            .build()
            .add(createMintBuilder)
            .add(createTokenBuilder)
            .add(mintTokenBuilder)
    }
}
