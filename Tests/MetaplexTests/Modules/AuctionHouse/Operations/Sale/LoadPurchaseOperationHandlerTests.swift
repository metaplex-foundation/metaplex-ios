//
//  LoadPurchaseOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

import AuctionHouse
import Foundation
import Solana
import XCTest

@testable import Metaplex

final class LoadPurchaseOperationHandlerTests: XCTestCase {
    func testLoadPurchaseOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        TestDataProvider.airDropFunds(metaplex, account: auctionHouse.auctionHouseFeeAccount)

        guard let account = HotAccount(),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create auction house") }

        guard let bid = BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)
        else { return XCTFail("Couldn't create bid") }

        guard let listing = ListingDataProvider.createListing(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)
        else { return XCTFail("Couldn't create listing") }

        guard let purchase = PurchaseDataProvider.executeSale(metaplex, bid: bid, listing: listing, auctionHouse: auctionHouse)?.purchaseReceipt
        else { return XCTFail("Couldn't execute sale") }

        guard let expectedPurchase = PurchaseDataProvider.loadPurchase(metaplex, purchase: purchase)?.purchaseReceipt
        else { return XCTFail("Couldn't load purchase") }

        XCTAssertEqual(purchase.bookkeeper, expectedPurchase.bookkeeper)
        XCTAssertEqual(purchase.auctionHouse.address, expectedPurchase.auctionHouse.address)
        XCTAssertEqual(purchase.buyer, expectedPurchase.buyer)
        XCTAssertEqual(purchase.metadata, expectedPurchase.metadata)
        XCTAssertEqual(purchase.receipt, expectedPurchase.receipt)
    }
}
