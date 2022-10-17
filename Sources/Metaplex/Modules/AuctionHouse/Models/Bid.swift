//
//  Bid.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/27/22.
//

import AuctionHouse
import Foundation
import Solana

struct Bid {
    let bidReceipt: LazyBid
    let nft: NFT
}

struct LazyBid {
    let auctionHouse: Auctionhouse
    let tradeState: Pda
    let bookkeeper: PublicKey?
    let buyer: PublicKey
    let metadata: PublicKey
    let tokenAddress: PublicKey?
    let receipt: Pda?
    let purchaseReceipt: PublicKey?
    let price: UInt64
    let tokenSize: UInt64
    let createdAt: Int64
    let canceledAt: Int64?

    init(
        auctionHouse: Auctionhouse,
        tradeState: Pda,
        bookkeeper: PublicKey?,
        buyer: PublicKey,
        metadata: PublicKey,
        tokenAddress: PublicKey?,
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
        self.buyer = buyer
        self.metadata = metadata
        self.tokenAddress = tokenAddress
        self.receipt = receipt
        self.purchaseReceipt = purchaseReceipt
        self.price = price
        self.tokenSize = tokenSize
        self.createdAt = createdAt
        self.canceledAt = canceledAt
    }

    init(auctionHouse: Auctionhouse, bidReceipt: Bidreceipt, publicKey: PublicKey) {
        self.auctionHouse = auctionHouse
        self.tradeState = Pda(publicKey: bidReceipt.tradeState, bump: bidReceipt.tradeStateBump)
        self.bookkeeper = bidReceipt.bookkeeper
        self.buyer = bidReceipt.buyer
        self.metadata = bidReceipt.metadata
        self.tokenAddress = bidReceipt.tokenAddress
        self.receipt = Pda(publicKey: publicKey, bump: bidReceipt.bump)
        self.purchaseReceipt = bidReceipt.purchaseReceipt
        self.price = bidReceipt.price
        self.tokenSize = bidReceipt.tokenSize
        self.createdAt = bidReceipt.createdAt
        self.canceledAt = bidReceipt.canceledAt
    }
}

extension Bidreceipt {
    var tokenAddress: PublicKey? {
        switch tokenAccount {
        case .some(let publicKey):
            return publicKey
        case .none:
            return nil
        }
    }

    static func pda(tradeStateAddress: PublicKey) -> Result<Pda, Error> {
        let seeds = [
            "bid_receipt".bytes,
            tradeStateAddress.bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map {
            Pda(publicKey: $0.0, bump: $0.1)
        }
    }
}
