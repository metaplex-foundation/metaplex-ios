//
//  FindBidByReceiptOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/25/22.
//

import Foundation
import Solana
import XCTest

@testable import Metaplex

final class FindBidByReceiptOperationHandlerTests: XCTestCase {
    func testFindBidByReceiptOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseTestDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        TestDataProvider.airDropFunds(metaplex, account: auctionHouse.auctionHouseFeeAccount)

        guard let account = HotAccount(network: .testnet),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create auction house") }

        guard let bid = AuctionHouseTestDataProvider.createBid(metaplex, auctionHouse: auctionHouse, nft: nft)?.bidReceipt
        else { return XCTFail("Couldn't create bid") }

        guard let address = bid.receipt?.publicKey
        else { return XCTFail("Missing receipt") }

        guard let expectedBid = AuctionHouseTestDataProvider.findBidByReceipt(metaplex, address: address, auctionHouse: auctionHouse)?.bidReceipt
        else { return XCTFail("Couldn't find bid") }

        XCTAssertEqual(bid.tradeState.publicKey, expectedBid.tradeState.publicKey)
        XCTAssertEqual(bid.bookkeeper, expectedBid.bookkeeper)
        XCTAssertEqual(bid.auctionHouse.address, expectedBid.auctionHouse.address)
        XCTAssertEqual(bid.buyer, expectedBid.buyer)
        XCTAssertEqual(bid.metadata, expectedBid.metadata)
        XCTAssertEqual(bid.receipt?.publicKey, expectedBid.receipt?.publicKey)
    }
}

