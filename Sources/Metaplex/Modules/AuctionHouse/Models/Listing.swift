//
//  Listing.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation
import Solana

struct Listing {
    let listingReceipt: LazyListing
    let nft: NFT
}

struct LazyListing {
    let auctionHouse: Auctionhouse
    let tradeState: Pda
    let seller: PublicKey
    let bookkeeper: PublicKey?
    let receipt: Pda?
    let purchaseReceipt: PublicKey?
    let price: UInt64
    let tokenSize: UInt64
    let createdAt: Int64
    let canceledAt: Int64?

    init(
        auctionHouse: Auctionhouse,
        tradeState: Pda,
        seller: PublicKey,
        bookkeeper: PublicKey?,
        receipt: Pda?,
        purchaseReceipt: PublicKey?,
        price: UInt64,
        tokenSize: UInt64,
        createdAt: Int64,
        canceledAt: Int64?
    ) {
        self.auctionHouse = auctionHouse
        self.tradeState = tradeState
        self.seller = seller
        self.bookkeeper = bookkeeper
        self.receipt = receipt
        self.purchaseReceipt = purchaseReceipt
        self.price = price
        self.tokenSize = tokenSize
        self.createdAt = createdAt
        self.canceledAt = canceledAt
    }

    init(auctionHouse: Auctionhouse, listingReceipt: Listingreceipt, publicKey: PublicKey) {
        self.auctionHouse = auctionHouse
        self.tradeState = Pda(publicKey: listingReceipt.tradeState, bump: listingReceipt.tradeStateBump)
        self.seller = listingReceipt.seller
        self.bookkeeper = listingReceipt.bookkeeper
        self.receipt = Pda(publicKey: publicKey, bump: listingReceipt.bump)
        self.purchaseReceipt = listingReceipt.purchaseReceipt
        self.price = listingReceipt.price
        self.tokenSize = listingReceipt.tokenSize
        self.createdAt = listingReceipt.createdAt
        self.canceledAt = listingReceipt.canceledAt
    }
}
