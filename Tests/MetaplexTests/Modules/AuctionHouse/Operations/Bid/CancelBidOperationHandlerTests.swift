//
//  CancelBidOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/25/22.
//

import Foundation
import Solana
import XCTest

@testable import Metaplex

final class CancelBidOperationHandlerTests: XCTestCase {
    func testCancelAuctionHouseOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseTestDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        TestDataProvider.airDropFunds(metaplex, account: auctionHouse.auctionHouseFeeAccount)

        guard let account = HotAccount(network: .testnet),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create auction house") }

        guard let bid = AuctionHouseTestDataProvider.createBid(metaplex, auctionHouse: auctionHouse, nft: nft)
        else { return XCTFail("Couldn't create bid") }

        guard let signatureStatus = AuctionHouseTestDataProvider.cancelBid(metaplex, auctionHouse: auctionHouse, bid: bid)
        else { return XCTFail("Couldn't cancel bid") }

        XCTAssertNotNil(signatureStatus)

        let address = bid.bidReceipt.tradeState.publicKey
        guard let canceledBid = AuctionHouseTestDataProvider.findBidByTradeState(metaplex, address: address, auctionHouse: auctionHouse)
        else { return XCTFail("Couldn't find bid") }

        XCTAssertNotNil(canceledBid.bidReceipt.canceledAt)
    }
}
