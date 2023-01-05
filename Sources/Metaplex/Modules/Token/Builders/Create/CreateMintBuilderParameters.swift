//
//  CreateMintBuilderParameters.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/7/22.
//

import Foundation
import Solana

struct CreateMintBuilderParameters {
    let tokenProgramId: PublicKey
    let payerSigner: Account
    let mintSigner: Account
    let decimals: UInt8
    let authority: PublicKey
    let freezeAuthority: PublicKey

    init(
        tokenProgramId: PublicKey = .tokenProgramId,
        payerSigner: Account,
        mintSigner: Account,
        decimals: UInt8 = 0,
        authority: PublicKey? = nil,
        freezeAuthority: PublicKey? = nil
    ) {
        self.tokenProgramId = tokenProgramId
        self.payerSigner = payerSigner
        self.mintSigner = mintSigner
        self.decimals = decimals
        self.authority = authority ?? payerSigner.publicKey
        self.freezeAuthority = freezeAuthority ?? payerSigner.publicKey
    }

    // MARK: - Getters

    var mint: PublicKey { mintSigner.publicKey }
    var createAccountParameters: CreateAccountBuilderParameters {
        CreateAccountBuilderParameters(
            payerSigner: payerSigner,
            newAccountSigner: mintSigner,
            lamports: MIN_RENT_FOR_MINT,
            space: MINT_SIZE
        )
    }
}
