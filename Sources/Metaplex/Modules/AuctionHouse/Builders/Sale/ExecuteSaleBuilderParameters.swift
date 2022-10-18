//
//  ExecuteSaleBuilderParameters.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/18/22.
//

import AuctionHouse
import Foundation
import Solana

struct ExecuteSaleBuilderParameters {
    // MARK: - Initialization

    let executeSaleInput: ExecuteSaleInput
    let tokenAccount: PublicKey
    let escrowPayment: Pda
    let sellerPaymentReceiptAccount: PublicKey
    let buyerReceiptTokenAccount: PublicKey
    let auctionHouseAddress: PublicKey
    let freeTradeStateAccount: Pda
    let programAsSignerAccount: Pda

    let defaultIdentity: Account

    // MARK: - Getters

    var buyer: PublicKey {
        executeSaleInput.bid.bidReceipt.buyer
    }

    var seller: PublicKey {
        executeSaleInput.listing.listingReceipt.seller
    }

    var tokenMint: PublicKey {
        nft.mint
    }

    var metadata: PublicKey {
        nft.metadataAccount.mint
    }

    var treasuryMint: PublicKey {
        executeSaleInput.auctionHouse.treasuryMint
    }

    var escrowPaymentAccount: PublicKey {
        escrowPayment.publicKey
    }

    var authority: PublicKey {
        executeSaleInput.auctionHouse.authority
    }

    var auctionHouseFeeAccount: PublicKey {
        executeSaleInput.auctionHouse.auctionHouseFeeAccount
    }

    var auctionHouseTreasury: PublicKey {
        executeSaleInput.auctionHouse.auctionHouseTreasury
    }

    var buyerTradeState: PublicKey {
        executeSaleInput.bid.bidReceipt.tradeState.publicKey
    }

    var sellerTradeState: PublicKey {
        executeSaleInput.listing.listingReceipt.tradeState.publicKey
    }

    var freeTradeState: PublicKey {
        freeTradeStateAccount.publicKey
    }

    var programAsSigner: PublicKey {
        programAsSignerAccount.publicKey
    }

    var escrowPaymentBump: UInt8 {
        escrowPayment.bump
    }

    var freeTradeStateBump: UInt8 {
        freeTradeStateAccount.bump
    }

    var programAsSignerBump: UInt8 {
        programAsSignerAccount.bump
    }

    var buyerPrice: UInt64 {
        isPartialSale ? executeSaleInput.listing.listingReceipt.price : executeSaleInput.bid.bidReceipt.price
    }

    var tokenSize: UInt64 {
        isPartialSale ? executeSaleInput.listing.listingReceipt.tokenSize : executeSaleInput.bid.bidReceipt.tokenSize
    }

    var partialOrderSize: UInt64 {
        executeSaleInput.bid.bidReceipt.tokenSize
    }

    var partialOrderPrice: UInt64 {
        executeSaleInput.bid.bidReceipt.price
    }

    var isPartialSale: Bool {
        executeSaleInput.bid.bidReceipt.tokenSize < executeSaleInput.listing.listingReceipt.tokenSize
    }

    var nft: NFT {
        executeSaleInput.listing.nft
    }

    var auctioneerAuthority: Account? {
        executeSaleInput.auctioneerAuthority
    }

    var auctioneerPda: PublicKey? {
        guard let auctioneerAuthority else { return nil }
        return try? Auctionhouse.auctioneerPda(
            auctionHouse: auctionHouseAddress,
            auctioneerAuthority: auctioneerAuthority.publicKey
        ).get()
    }

    var printReceipt: (shouldPrintReceipt: Bool, receipt: Pda?) {
        let shouldPrintReceipt = executeSaleInput.printReceipt
        let receipt = shouldPrintReceipt ? try? Bidreceipt.pda(tradeStateAddress: sellerTradeState).get() : nil
        return (shouldPrintReceipt, receipt)
    }

    var listingReceiptAddress: PublicKey? {
        executeSaleInput.listing.listingReceipt.receipt?.publicKey
    }

    var bidReceiptAddress: PublicKey? {
        executeSaleInput.bid.bidReceipt.receipt?.publicKey
    }

    var bookkeeper: Account {
        executeSaleInput.bookkeeper ?? defaultIdentity
    }
}
