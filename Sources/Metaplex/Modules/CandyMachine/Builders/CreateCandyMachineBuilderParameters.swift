//
//  CreateCandyMachineBuilderParameters.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/3/22.
//

import CandyMachine
import Foundation
import Solana

struct CreateCandyMachineBuilderParameters {
    // MARK: - Initialization

    private let createCandyMachineInput: CreateCandyMachineInput
    private let defaultIdentity: Account
    let lamports: UInt64

    init(
        createCandyMachineInput: CreateCandyMachineInput,
        defaultIdentity: Account,
        lamports: UInt64
    ) {
        self.createCandyMachineInput = createCandyMachineInput
        self.defaultIdentity = defaultIdentity
        self.lamports = lamports
    }

    // MARK: - Getters

    var tokenMint: PublicKey? { createCandyMachineInput.tokenMint }
    var collection: PublicKey? { createCandyMachineInput.collection }

    // MARK: - Accounts

    var candyMachine: PublicKey { candyMachineSigner.publicKey }
    var wallet: PublicKey { walletSigner.publicKey }
    var authority: PublicKey { authoritySigner.publicKey }
    var payer: PublicKey { payerSigner.publicKey }

    var space: UInt64 { createCandyMachineInput.accountSize }
    var programPubkey: PublicKey { CandyMachineProgram.programId }

    // MARK: - Args

    var data: CandyMachineData { createCandyMachineInput.data }

    // MARK: - Signers

    var candyMachineSigner: Account { createCandyMachineInput.candyMachine }
    var walletSigner: Account { createCandyMachineInput.wallet ?? defaultIdentity }
    var payerSigner: Account { createCandyMachineInput.payer ?? defaultIdentity }
    var authoritySigner: Account { createCandyMachineInput.authority ?? defaultIdentity }
}
