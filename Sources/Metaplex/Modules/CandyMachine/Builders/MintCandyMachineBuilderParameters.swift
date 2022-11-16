//
//  MintCandyMachineBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/3/22.
//

import CandyMachine
import Foundation
import Solana

struct MintCandyMachineBuilderParameters {
    private let mintCandyMachineInput: MintCandyMachineInput
    private let candyMachineCreatorPda: Pda
    private let associatedAccount: PublicKey
    private let defaultIdentity: Account
    
    let metadata: PublicKey
    let masterEdition: PublicKey

    init(
        mintCandyMachineInput: MintCandyMachineInput,
        candyMachineCreatorPda: Pda,
        metadata: PublicKey,
        masterEdition: PublicKey,
        associatedAccount: PublicKey,
        defaultIdentity: Account
    ) {
        self.mintCandyMachineInput = mintCandyMachineInput
        self.candyMachineCreatorPda = candyMachineCreatorPda
        self.metadata = metadata
        self.masterEdition = masterEdition
        self.associatedAccount = associatedAccount
        self.defaultIdentity = defaultIdentity
    }


    // MARK: - Getters

    var createTokenWithMintParameters: CreateTokenWithMintBuilderParameters {
        CreateTokenWithMintBuilderParameters(
            payerSigner: payerSigner,
            mintSigner: mintCandyMachineInput.newMint,
            associatedAccount: associatedAccount
        )
    }

    var tokenMint: PublicKey? { mintCandyMachineInput.candyMachine.tokenMint }
    var payerToken: PublicKey? {
        mintCandyMachineInput.payerToken
    }

    // MARK: - Accounts

    var candyMachine: PublicKey { mintCandyMachineInput.candyMachine.address }
    var candyMachineCreator: PublicKey { candyMachineCreatorPda.publicKey }
    var payer: PublicKey { payerSigner.publicKey }
    var wallet: PublicKey { mintCandyMachineInput.candyMachine.wallet }
    var mint: PublicKey { mintSigner.publicKey }
    var mintAuthority: PublicKey { payer }
    var updateAuthority: PublicKey { payer }
    var tokenMetadataProgram: PublicKey { TokenMetadataProgram.publicKey }
    var clock: PublicKey { SYSVAR_CLOCK_PUBKEY }
    var recentBlockhashes: PublicKey { SYSVAR_SLOT_HASHES_PUBKEY }
    var instructionSysvarAccount: PublicKey { SYSVAR_INSTRUCTIONS_PUBKEY }

    // MARK: - Args

    var creatorBump: UInt8 { candyMachineCreatorPda.bump }

    // MARK: - Signers

    var payerSigner: Account { mintCandyMachineInput.payer ?? defaultIdentity }
    var mintSigner: Account { mintCandyMachineInput.newMint }
}
