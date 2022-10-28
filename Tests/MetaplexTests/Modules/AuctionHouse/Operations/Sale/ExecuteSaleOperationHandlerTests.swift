//
//  ExecuteSaleOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

import AuctionHouse
import Foundation
import Solana
import XCTest

@testable import Metaplex

final class ExecuteSaleOperationHandlerTests: XCTestCase {
    func testExecuteSaleOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        TestDataProvider.airDropFunds(metaplex, account: auctionHouse.auctionHouseFeeAccount)

        guard let account = HotAccount(network: .testnet),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create auction house") }

        guard let bid = BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, nft: nft)
        else { return XCTFail("Couldn't create bid") }

        guard let listing = ListingDataProvider.createListing(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)
        else { return XCTFail("Couldn't create listing") }

        guard let purchase = PurchaseDataProvider.executeSale(metaplex, bid: bid, listing: listing, auctionHouse: auctionHouse)
        else { return XCTFail("Couldn't execute sale") }

        XCTAssertEqual(purchase.purchaseReceipt.auctionHouse.address, auctionHouse.address)
        XCTAssertEqual(purchase.nft.mint, nft.mint)
    }
}
