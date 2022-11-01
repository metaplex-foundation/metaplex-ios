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
    public let auctionHouse: AuctionhouseArgs
    public let tradeState: Pda
    public let bookkeeper: PublicKey?
    public let seller: PublicKey
    public let metadata: PublicKey
    public let receipt: Pda?
    public let purchaseReceipt: PublicKey?
    public let price: UInt64
    public let tokenSize: UInt64
    public let createdAt: Int64
    public let canceledAt: Int64?

    public init(
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

    public init(auctionHouse: AuctionhouseArgs, listingReceipt: Listingreceipt, publicKey: PublicKey) {
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

extension Listingreceipt {
    static func pda(tradeStateAddress: PublicKey) -> Result<Pda, Error> {
        let seeds = [
            "listing_receipt".bytes,
            tradeStateAddress.bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map {
            Pda(publicKey: $0.0, bump: $0.1)
        }
    }
}
