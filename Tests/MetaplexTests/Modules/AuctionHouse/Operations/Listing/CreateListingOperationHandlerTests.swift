//
//  CreateListingOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

import AuctionHouse
import Foundation
import Solana
import XCTest

@testable import Metaplex

final class CreateListingOperationHandlerTests: XCTestCase {
    func testCreateListingOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        TestDataProvider.airDropFunds(metaplex, account: auctionHouse.auctionHouseFeeAccount)

        guard let account = HotAccount(),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create auction house") }

        guard let listing = ListingDataProvider.createListing(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)
        else { return XCTFail("Couldn't create listing") }

        XCTAssertEqual(listing.listingReceipt.auctionHouse.address, auctionHouse.address)
        XCTAssertEqual(listing.nft.mint, nft.mint)
    }
}
