//
//  Purchase.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/18/22.
//

import AuctionHouse
import Foundation
import Solana

public struct Purchase {
    let purchaseReceipt: LazyPurchase
    let nft: NFT
}

public struct LazyPurchase {
    let auctionHouse: AuctionhouseArgs
    let buyer: PublicKey
    let seller: PublicKey
    let metadata: PublicKey
    let bookkeeper: PublicKey
    let receipt: PublicKey?
    let price: UInt64
    let tokenSize: UInt64
    let createdAt: Int64

    init(
        auctionHouse: AuctionhouseArgs,
        buyer: PublicKey,
        seller: PublicKey,
        metadata: PublicKey,
        bookkeeper: PublicKey,
        receipt: PublicKey?,
        price: UInt64,
        tokenSize: UInt64,
        createdAt: Int64
    ) {
        self.auctionHouse = auctionHouse
        self.buyer = buyer
        self.seller = seller
        self.metadata = metadata
        self.bookkeeper = bookkeeper
        self.receipt = receipt
        self.price = price
        self.tokenSize = tokenSize
        self.createdAt = createdAt
    }

    init(auctionHouse: AuctionhouseArgs, purchaseReceipt: Purchasereceipt, publicKey: PublicKey) {
        self.auctionHouse = auctionHouse
        self.buyer = purchaseReceipt.buyer
        self.seller = purchaseReceipt.seller
        self.metadata = purchaseReceipt.metadata
        self.bookkeeper = purchaseReceipt.bookkeeper
        self.receipt = publicKey
        self.price = purchaseReceipt.price
        self.tokenSize = purchaseReceipt.tokenSize
        self.createdAt = purchaseReceipt.createdAt
    }
}
