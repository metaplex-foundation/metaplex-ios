//
//  CreateListingBuilderParameters.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation
import Solana

struct CreateListingBuilderParameters {
    // MARK: - Initialization

    private let createListingInput: CreateListingInput
    private let sellerTradeStatePda: Pda
    private let freeSellerTradeStatePda: Pda
    private let programAsSignerPda: Pda
    private let defaultIdentity: Account

    let tokenAccount: PublicKey
    let metadata: PublicKey
    let auctionHouse: PublicKey

    init(
        createListingInput: CreateListingInput,
        sellerTradeStatePda: Pda,
        freeSellerTradeStatePda: Pda,
        programAsSignerPda: Pda,
        defaultIdentity: Account,
        tokenAccount: PublicKey,
        metadata: PublicKey,
        auctionHouse: PublicKey
    ) {
        self.createListingInput = createListingInput
        self.sellerTradeStatePda = sellerTradeStatePda
        self.freeSellerTradeStatePda = freeSellerTradeStatePda
        self.programAsSignerPda = programAsSignerPda
        self.defaultIdentity = defaultIdentity
        self.tokenAccount = tokenAccount
        self.metadata = metadata
        self.auctionHouse = auctionHouse
    }

    // MARK: - Getters

    var shouldPrintReceipt: Bool { createListingInput.printReceipt }
    var receipt: Pda? { shouldPrintReceipt ? try? Listingreceipt.pda(tradeStateAddress: sellerTradeState).get() : nil }

    // MARK: - Accounts

    var wallet: PublicKey { sellerSigner.publicKey }
    var authority: PublicKey { createListingInput.authority?.publicKey ?? createListingInput.auctionHouse.authority }
    var auctionHouseFeeAccount: PublicKey { createListingInput.auctionHouse.auctionHouseFeeAccount }
    var sellerTradeState: PublicKey { sellerTradeStatePda.publicKey }
    var freeSellerTradeState: PublicKey { freeSellerTradeStatePda.publicKey }
    var programAsSigner: PublicKey { programAsSignerPda.publicKey }
    var auctioneerPda: PublicKey? {
        guard let auctioneerAuthoritySigner else { return nil }
        return try? Auctionhouse.auctioneerPda(
            auctionHouse: auctionHouse,
            auctioneerAuthority: auctioneerAuthoritySigner.publicKey
        ).get()
    }
    var bookkeeper: PublicKey { bookkeeperSigner.publicKey }

    // MARK: - Args

    var tradeStateBump: UInt8 { sellerTradeStatePda.bump }
    var freeTradeStateBump: UInt8 { freeSellerTradeStatePda.bump }
    var programAsSignerBump: UInt8 { programAsSignerPda.bump }
    var tokenSize: UInt64 { createListingInput.tokens }
    var buyerPrice: UInt64 { createListingInput.price }

    // MARK: - Signers

    var sellerSigner: Account { createListingInput.seller ?? defaultIdentity }
    var auctioneerAuthoritySigner: Account? { createListingInput.auctioneerAuthority }
    var bookkeeperSigner: Account { createListingInput.bookkeeper ?? defaultIdentity }
}
