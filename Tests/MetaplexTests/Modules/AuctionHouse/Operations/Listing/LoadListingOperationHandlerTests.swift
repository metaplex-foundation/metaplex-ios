//
//  LoadListingOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

//import AuctionHouse
//import Foundation
//import Solana
//import XCTest
//
//@testable import Metaplex
//
//final class LoadListingOperationHandlerTests: XCTestCase {
//    func testLoadListingOperation() {
//        let metaplex = TestDataProvider.createMetaplex()
//        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
//        else { return XCTFail("Couldn't create auction house") }
//
//        guard let account = HotAccount(),
//              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
//        else { return XCTFail("Couldn't create nft") }
//
//        guard let listing = ListingDataProvider.createListing(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)?.listingReceipt
//        else { return XCTFail("Couldn't create listing") }
//
//        guard let expectedListing = ListingDataProvider.loadListing(metaplex, listing: listing)?.listingReceipt
//        else { return XCTFail("Couldn't load listing") }
//
//        XCTAssertEqual(listing.tradeState.publicKey, expectedListing.tradeState.publicKey)
//        XCTAssertEqual(listing.bookkeeper, expectedListing.bookkeeper)
//        XCTAssertEqual(listing.auctionHouse.address, expectedListing.auctionHouse.address)
//        XCTAssertEqual(listing.seller, expectedListing.seller)
//        XCTAssertEqual(listing.metadata, expectedListing.metadata)
//        XCTAssertEqual(listing.receipt?.publicKey, expectedListing.receipt?.publicKey)
//    }
//}
