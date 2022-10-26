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

    private let executeSaleInput: ExecuteSaleInput
    private let escrowPaymentPda: Pda
    private let freeTradeStatePda: Pda
    private let programAsSignerPda: Pda
    private let defaultIdentity: Account

    let tokenAccount: PublicKey
    let sellerPaymentReceiptAccount: PublicKey
    let buyerReceiptTokenAccount: PublicKey
    let auctionHouse: PublicKey

    init(
        executeSaleInput: ExecuteSaleInput,
        escrowPaymentPda: Pda,
        freeTradeStatePda: Pda,
        programAsSignerPda: Pda,
        defaultIdentity: Account,
        tokenAccount: PublicKey,
        sellerPaymentReceiptAccount: PublicKey,
        buyerReceiptTokenAccount: PublicKey,
        auctionHouse: PublicKey
    ) {
        self.executeSaleInput = executeSaleInput
        self.escrowPaymentPda = escrowPaymentPda
        self.freeTradeStatePda = freeTradeStatePda
        self.programAsSignerPda = programAsSignerPda
        self.defaultIdentity = defaultIdentity
        self.tokenAccount = tokenAccount
        self.sellerPaymentReceiptAccount = sellerPaymentReceiptAccount
        self.buyerReceiptTokenAccount = buyerReceiptTokenAccount
        self.auctionHouse = auctionHouse
    }

    // MARK: - Getters

    var isPartialSale: Bool {
        executeSaleInput.bid.bidReceipt.tokenSize < executeSaleInput.listing.listingReceipt.tokenSize
    }
    var nft: NFT { executeSaleInput.listing.nft }
    var isNative: Bool { executeSaleInput.auctionHouse.isNative }
    var shouldPrintReceipt: Bool { executeSaleInput.printReceipt }
    var receipt: Pda? { shouldPrintReceipt ? try? Bidreceipt.pda(tradeStateAddress: sellerTradeState).get() : nil }

    // MARK: - Accounts

    var buyer: PublicKey { executeSaleInput.bid.bidReceipt.buyer }
    var seller: PublicKey { executeSaleInput.listing.listingReceipt.seller }
    var tokenMint: PublicKey { nft.mint }
    var metadata: PublicKey { nft.metadataAccount.mint }
    var treasuryMint: PublicKey { executeSaleInput.auctionHouse.treasuryMint }
    var escrowPaymentAccount: PublicKey { escrowPaymentPda.publicKey }
    var authority: PublicKey { executeSaleInput.auctionHouse.authority }
    var auctionHouseFeeAccount: PublicKey { executeSaleInput.auctionHouse.auctionHouseFeeAccount }
    var auctionHouseTreasury: PublicKey { executeSaleInput.auctionHouse.auctionHouseTreasury }
    var buyerTradeState: PublicKey { executeSaleInput.bid.bidReceipt.tradeState.publicKey }
    var sellerTradeState: PublicKey { executeSaleInput.listing.listingReceipt.tradeState.publicKey }
    var freeTradeState: PublicKey { freeTradeStatePda.publicKey }
    var programAsSigner: PublicKey { programAsSignerPda.publicKey }
    var auctioneerPda: PublicKey? {
        guard let auctioneerAuthoritySigner else { return nil }
        return try? Auctionhouse.auctioneerPda(
            auctionHouse: auctionHouse,
            auctioneerAuthority: auctioneerAuthoritySigner.publicKey
        ).get()
    }
    var listingReceiptAddress: PublicKey? { executeSaleInput.listing.listingReceipt.receipt?.publicKey }
    var bidReceiptAddress: PublicKey? { executeSaleInput.bid.bidReceipt.receipt?.publicKey }
    var bookkeeper: PublicKey { bookkeeperSigner.publicKey }

    // MARK: - Args

    var escrowPaymentBump: UInt8 { escrowPaymentPda.bump }
    var freeTradeStateBump: UInt8 { freeTradeStatePda.bump }
    var programAsSignerBump: UInt8 { programAsSignerPda.bump }
    var buyerPrice: UInt64 {
        isPartialSale ? executeSaleInput.listing.listingReceipt.price : executeSaleInput.bid.bidReceipt.price
    }
    var tokenSize: UInt64 {
        isPartialSale ? executeSaleInput.listing.listingReceipt.tokenSize : executeSaleInput.bid.bidReceipt.tokenSize
    }
    var partialOrderSize: UInt64 { executeSaleInput.bid.bidReceipt.tokenSize }
    var partialOrderPrice: UInt64 { executeSaleInput.bid.bidReceipt.price }

    // MARK: - Signers

    var auctioneerAuthoritySigner: Account? { executeSaleInput.auctioneerAuthority }
    var bookkeeperSigner: Account { executeSaleInput.bookkeeper ?? defaultIdentity }

}
