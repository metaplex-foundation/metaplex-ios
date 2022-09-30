//
//  BidReceiptGpaBuilder.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/29/22.
//

import AuctionHouse
import Foundation
import Solana

class BidReceiptGpaBuilder: GpaBuilder {
    private struct Offsets {
        private static let publicKey = UInt(PublicKey.default.bytes.count)

        static let auctionHouse = UInt(Bidreceipt.bidReceiptDiscriminator.count) + publicKey + publicKey
        static let buyer = auctionHouse + publicKey
        static let metadata = buyer + publicKey
    }

    let connection: Connection
    let programId: PublicKey
    var config: GetProgramAccountsConfig = GetProgramAccountsConfig(encoding: "base64")!

    required init(connection: Connection, programId: PublicKey) {
        self.connection = connection
        self.programId = programId
    }

    func bidReceiptAccounts() -> BidReceiptGpaBuilder {
        var mutableGpaBuilder = self
        return mutableGpaBuilder.where(offset: 0, bytes: Bidreceipt.bidReceiptDiscriminator)
    }

    func whereAuctionHouse(address: PublicKey) -> BidReceiptGpaBuilder {
        var mutableGpaBuilder = self
        return mutableGpaBuilder.where(offset: Offsets.auctionHouse, publicKey: address)
    }

    func whereBuyer(address: PublicKey) -> BidReceiptGpaBuilder {
        var mutableGpaBuilder = self
        return mutableGpaBuilder.where(offset: Offsets.buyer, publicKey: address)
    }

    func whereMetadata(address: PublicKey) -> BidReceiptGpaBuilder {
        var mutableGpaBuilder = self
        return mutableGpaBuilder.where(offset: Offsets.metadata, publicKey: address)
    }
}
