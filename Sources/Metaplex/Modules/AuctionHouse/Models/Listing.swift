//
//  Listing.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation
import Solana

public struct Listing {
    let listingReceipt: LazyListing
    let nft: NFT
}

public struct LazyListing {
    let auctionHouse: AuctionhouseArgs
    let tradeState: Pda
    let bookkeeper: PublicKey?
    let seller: PublicKey
    let metadata: PublicKey
    let receipt: Pda?
    let purchaseReceipt: PublicKey?
    let price: UInt64
    let tokenSize: UInt64
    let createdAt: Int64
    let canceledAt: Int64?

    init(
        auctionHouse: AuctionhouseArgs,
        tradeState: Pda,
        bookkeeper: PublicKey?,
        seller: PublicKey,
        metadata: PublicKey,
        receipt: Pda?,
        purchaseReceipt: PublicKey?,
        price: UInt64,
        tokenSize: UInt64,
        createdAt: Int64,
        canceledAt: Int64?
    ) {
        self.auctionHouse = auctionHouse
        self.tradeState = tradeState
        self.bookkeeper = bookkeeper
        self.seller = seller
        self.metadata = metadata
        self.receipt = receipt
        self.purchaseReceipt = purchaseReceipt
        self.price = price
        self.tokenSize = tokenSize
        self.createdAt = createdAt
        self.canceledAt = canceledAt
    }

    init(auctionHouse: AuctionhouseArgs, listingReceipt: Listingreceipt, publicKey: PublicKey) {
        self.auctionHouse = auctionHouse
        self.tradeState = Pda(publicKey: listingReceipt.tradeState, bump: listingReceipt.tradeStateBump)
        self.bookkeeper = listingReceipt.bookkeeper
        self.seller = listingReceipt.seller
        self.metadata = listingReceipt.metadata
        self.receipt = Pda(publicKey: publicKey, bump: listingReceipt.bump)
        self.purchaseReceipt = listingReceipt.purchaseReceipt
        self.price = listingReceipt.price
        self.tokenSize = listingReceipt.tokenSize
        self.createdAt = listingReceipt.createdAt
        self.canceledAt = listingReceipt.canceledAt
    }
}
