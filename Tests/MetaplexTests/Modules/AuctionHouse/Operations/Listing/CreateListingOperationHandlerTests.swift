//
//  CreateListingOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//
/// All Auction House tests are set to run locally using `amman`, but are commented out so CI can pass. To run these tests you will need the [js sdk](git@github.com:metaplex-foundation/js.git). With the repo cloned, from the terminal run the following commands from the `js` directory:
///
/// ```
/// yarn install
/// yarn amman:start
/// ```

//import AuctionHouse
//import Foundation
//import Solana
//import XCTest
//
//@testable import Metaplex
//
//final class CreateListingOperationHandlerTests: XCTestCase {
//    func testCreateListingOperation() {
//        let metaplex = TestDataProvider.createMetaplex()
//        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
//        else { return XCTFail("Couldn't create auction house") }
//
//        guard let account = HotAccount(),
//              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
//        else { return XCTFail("Couldn't create nft") }
//
//        guard let listing = ListingDataProvider.createListing(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)
//        else { return XCTFail("Couldn't create listing") }
//
//        XCTAssertEqual(listing.listingReceipt.auctionHouse.address, auctionHouse.address)
//        XCTAssertEqual(listing.nft.mint, nft.mint)
//    }
//}
