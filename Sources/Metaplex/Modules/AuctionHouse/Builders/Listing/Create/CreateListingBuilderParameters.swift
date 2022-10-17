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

    let createListingInput: CreateListingInput
    let metadata: PublicKey
    let tokenAccount: PublicKey
    let sellerTradeStatePda: Pda
    let freeSellerTradeStatePda: Pda
    let programAsSignerPda: Pda
    let auctionHouseAddress: PublicKey
    let defaultIdentity: Account

    // MARK: - Getters

    var wallet: PublicKey {
        seller.publicKey
    }

    var authority: PublicKey {
        createListingInput.authority?.publicKey ?? createListingInput.auctionHouse.authority
    }

    var auctionHouseFeeAccount: PublicKey {
        createListingInput.auctionHouse.auctionHouseFeeAccount
    }

    var sellerTradeState: PublicKey {
        sellerTradeStatePda.publicKey
    }

    var freeSellerTradeState: PublicKey {
        freeSellerTradeStatePda.publicKey
    }

    var programAsSigner: PublicKey {
        programAsSignerPda.publicKey
    }

    var tradeStateBump: UInt8 {
        sellerTradeStatePda.bump
    }

    var freeTradeStateBump: UInt8 {
        freeSellerTradeStatePda.bump
    }

    var programAsSignerBump: UInt8 {
        programAsSignerPda.bump
    }

    var tokenSize: UInt64 {
        createListingInput.tokens
    }

    var buyerPrice: UInt64 {
        createListingInput.price
    }

    var auctioneerAuthority: Account? {
        createListingInput.auctioneerAuthority
    }

    var seller: Account {
        createListingInput.seller ?? defaultIdentity
    }

    var auctioneerPda: PublicKey? {
        guard let auctioneerAuthority else { return nil }
        return try? Auctionhouse.auctioneerPda(
            auctionHouse: auctionHouseAddress,
            auctioneerAuthority: auctioneerAuthority.publicKey
        ).get()
    }

    var printReceipt: (shouldPrintReceipt: Bool, receipt: Pda?) {
        let shouldPrintReceipt = createListingInput.printReceipt
        let receipt = shouldPrintReceipt ? try? Bidreceipt.pda(tradeStateAddress: sellerTradeState).get() : nil
        return (shouldPrintReceipt, receipt)
    }

    var bookkeeper: Account {
        createListingInput.bookkeeper ?? defaultIdentity
    }
}
