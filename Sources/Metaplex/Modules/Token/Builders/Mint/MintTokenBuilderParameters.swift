//
//  MintTokenBuilderParameters.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/7/22.
//

import Foundation
import Solana

struct MintTokenBuilderParameters {
    let payerSigner: Account
    let mintSigner: Account
    let destination: PublicKey
    let mintAuthority: Account
    let amount: UInt64
    let tokenProgramId: PublicKey

    init(
        payerSigner: Account,
        mintSigner: Account,
        destination: PublicKey,
        mintAuthority: Account? = nil,
        amount: UInt64 = 1,
        tokenProgramId: PublicKey = .tokenProgramId
    ) {
        self.payerSigner = payerSigner
        self.mintSigner = mintSigner
        self.destination = destination
        self.mintAuthority = mintAuthority ?? payerSigner
        self.amount = amount
        self.tokenProgramId = tokenProgramId
    }

    // MARK: - Getters

    var mint: PublicKey { mintSigner.publicKey }
    var authority: PublicKey { mintAuthority.publicKey }
}
