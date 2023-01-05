//
//  CreateAuctionHouseBuilderParameters.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/21/22.
//

import AuctionHouse
import Foundation
import Solana

struct CreateAuctionHouseBuilderParameters {
    // MARK: - Initialization

    private let createAuctionHouseInput: CreateAuctionHouseInput
    private let auctionHousePda: Pda
    private let auctionHouseFeePda: Pda
    private let auctionHouseTreasuryPda: Pda
    private let defaultIdentity: Account

    let treasuryWithdrawalDestination: PublicKey

    init(
        createAuctionHouseInput: CreateAuctionHouseInput,
        auctionHousePda: Pda,
        auctionHouseFeePda: Pda,
        auctionHouseTreasuryPda: Pda,
        treasuryWithdrawalDestination: PublicKey,
        defaultIdentity: Account
    ) {
        self.createAuctionHouseInput = createAuctionHouseInput
        self.auctionHousePda = auctionHousePda
        self.auctionHouseFeePda = auctionHouseFeePda
        self.auctionHouseTreasuryPda = auctionHouseTreasuryPda
        self.treasuryWithdrawalDestination = treasuryWithdrawalDestination
        self.defaultIdentity = defaultIdentity
    }

    // MARK: - Getters

    // MARK: - Accounts

    var treasuryMint: PublicKey { createAuctionHouseInput.treasuryMint }
    var payer: PublicKey { payerSigner.publicKey }
    var authority: PublicKey { authoritySigner.publicKey }
    var feeWithdrawalDestination: PublicKey { feeWithdrawalDestinationSigner.publicKey }
    var treasuryWithdrawalDestinationOwner: PublicKey {
        createAuctionHouseInput.treasuryWithdrawalDestinationOwner ?? defaultIdentity.publicKey
    }
    var auctionHouse: PublicKey { auctionHousePda.publicKey }
    var auctionHouseFeeAccount: PublicKey { auctionHouseFeePda.publicKey }
    var auctionHouseTreasury: PublicKey { auctionHouseTreasuryPda.publicKey }
    var auctioneerPda: PublicKey? {
        guard let auctioneerAuthority else { return nil }
        return try? Auctionhouse.auctioneerPda(
            auctionHouse: auctionHouse,
            auctioneerAuthority: auctioneerAuthority
        ).get()
    }

    var auctioneerAuthority: PublicKey? { createAuctionHouseInput.auctioneerAuthority }

    // MARK: - Args

    var bump: UInt8 { auctionHousePda.bump }
    var feePayerBump: UInt8 { auctionHouseFeePda.bump }
    var treasuryBump: UInt8 { auctionHouseTreasuryPda.bump }
    var sellerFeeBasisPoints: UInt16 { createAuctionHouseInput.sellerFeeBasisPoints }
    var requiresSignOff: Bool { createAuctionHouseInput.requiresSignOff }
    var canChangeSalePrice: Bool { createAuctionHouseInput.canChangeSalePrice }

    var auctioneerScopes: [AuthorityScope] { createAuctionHouseInput.auctioneerScopes }

    // MARK: - Signers

    var payerSigner: Account { createAuctionHouseInput.payer ?? defaultIdentity }
    var authoritySigner: Account { createAuctionHouseInput.authority ?? defaultIdentity }
    var feeWithdrawalDestinationSigner: Account { createAuctionHouseInput.feeWithdrawalDestination ?? defaultIdentity }
}
