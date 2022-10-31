//
//  CreateBidOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/19/22.
//

import AuctionHouse
import Foundation
import Solana
import XCTest

@testable import Metaplex

final class CreateBidOperationTests: XCTestCase {
    func testCreateBidOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        guard let account = HotAccount(),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create nft") }

        guard let bid = BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)
        else { return XCTFail("Couldn't create bid") }

        XCTAssertEqual(bid.bidReceipt.auctionHouse.address, auctionHouse.address)
        XCTAssertEqual(bid.nft.mint, nft.mint)
    }

    func testCreateBidWithBuyer() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        guard let account = HotAccount(),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create nft") }

        let buyer = HotAccount()!
        TestDataProvider.airDropFunds(metaplex, account: buyer.publicKey)

        guard let bid = BidDataProvider.createBid(
            metaplex,
            auctionHouse: auctionHouse,
            mintAccount: nft.mint,
            buyer: buyer,
            seller: metaplex.identity()
        )
        else { return XCTFail("Couldn't create bid") }

        XCTAssertEqual(bid.bidReceipt.auctionHouse.address, auctionHouse.address)
        XCTAssertEqual(bid.nft.mint, nft.mint)
    }
}
