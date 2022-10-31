//
//  File.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

import Foundation
import Solana
import XCTest

@testable import Metaplex

final class FindListingByReceiptOperationHandlerTests: XCTestCase {
    func testFindListingByReceiptOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        guard let account = HotAccount(),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create nft") }

        guard let listing = ListingDataProvider.createListing(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)?.listingReceipt
        else { return XCTFail("Couldn't create listing") }

        guard let address = listing.receipt?.publicKey
        else { return XCTFail("Listing was created without a receipt address") }

        guard let expectedListing = ListingDataProvider.findListingByReceipt(metaplex, address: address, auctionHouse: auctionHouse)?.listingReceipt
        else { return XCTFail("Couldn't find listing") }

        XCTAssertEqual(listing.tradeState.publicKey, expectedListing.tradeState.publicKey)
        XCTAssertEqual(listing.bookkeeper, expectedListing.bookkeeper)
        XCTAssertEqual(listing.auctionHouse.address, expectedListing.auctionHouse.address)
        XCTAssertEqual(listing.seller, expectedListing.seller)
        XCTAssertEqual(listing.metadata, expectedListing.metadata)
        XCTAssertEqual(listing.receipt?.publicKey, expectedListing.receipt?.publicKey)
    }
}
