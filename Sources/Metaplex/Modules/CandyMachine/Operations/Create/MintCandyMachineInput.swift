//
//  MintCandyMachineInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/3/22.
//

import CandyMachine
import Foundation
import Solana

struct MintCandyMachineInput {
    let candyMachine: CandyMachine
    let payer: Account?
    let newMint: Account
    let newOwner: PublicKey?
    let newToken: PublicKey?
    let payerToken: PublicKey?
    let whitelistToken: PublicKey?

    init(
        candyMachine: CandyMachine,
        payer: Account? = nil,
        newMint: Account = HotAccount()!,
        newOwner: PublicKey? = nil,
        newToken: PublicKey? = nil,
        payerToken: PublicKey? = nil,
        whitelistToken: PublicKey? = nil
    ) {
        self.candyMachine = candyMachine
        self.payer = payer
        self.newMint = newMint
        self.newOwner = newOwner
        self.newToken = newToken
        self.payerToken = payerToken
        self.whitelistToken = whitelistToken
    }

    // MARK: - Getters

    var mint: PublicKey { newMint.publicKey }
}
