//
//  CreateBidOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/19/22.
//

import Foundation
import Solana
import XCTest

@testable import Metaplex

final class CreateBidOperationTests: XCTestCase {
    func testCreateBidOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseTestDataProvider.createAuctionHouse(metaplex) else { return XCTFail("Couldn't create auction house") }
        TestDataProvider.airDropFunds(metaplex, account: auctionHouse.auctionHouseFeeAccount)

        guard let account = HotAccount(network: .testnet),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create auction house") }

        guard let bid = AuctionHouseTestDataProvider.createBid(metaplex, auctionHouse: auctionHouse, nft: nft) else { return XCTFail("Couldn't create bid") }

        XCTAssertEqual(bid.bidReceipt.auctionHouse.address, auctionHouse.address)
        XCTAssertEqual(bid.nft.mint, nft.mint)
    }
}
