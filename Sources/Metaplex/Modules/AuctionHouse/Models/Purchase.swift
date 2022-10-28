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
    public let auctionHouse: AuctionhouseArgs
    public let buyer: PublicKey
    public let seller: PublicKey
    public let metadata: PublicKey
    public let bookkeeper: PublicKey
    public let receipt: PublicKey?
    public let price: UInt64
    public let tokenSize: UInt64
    public let createdAt: Int64

    public init(
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

    public init(auctionHouse: AuctionhouseArgs, purchaseReceipt: Purchasereceipt, publicKey: PublicKey) {
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

extension Purchasereceipt {
    static func pda(sellerTradeState: PublicKey, buyerTradeState: PublicKey) -> Result<Pda, Error> {
        let seeds = [
            "purchase_receipt".bytes,
            sellerTradeState.bytes,
            buyerTradeState.bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map {
            Pda(publicKey: $0.0, bump: $0.1)
        }
    }
}
