//
//  CancelListingOperationHandlerTests.swift
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

//import Foundation
//import Solana
//import XCTest
//
//@testable import Metaplex
//
//final class CancelListingOperationHandlerTests: XCTestCase {
//    func testCancelBidOperation() {
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
//        guard let signatureStatus = ListingDataProvider.cancelListing(metaplex, auctionHouse: auctionHouse, listing: listing)
//        else { return XCTFail("Couldn't cancel listing") }
//
//        XCTAssertNotNil(signatureStatus)
//
//        guard let address = listing.listingReceipt.receipt?.publicKey
//        else { return XCTFail("Listing was created without a receipt address") }
//        
//        guard let canceledListing = ListingDataProvider.findListingByReceipt(metaplex, address: address, auctionHouse: auctionHouse)
//        else { return XCTFail("Couldn't find listing") }
//
//        XCTAssertNotNil(canceledListing.listingReceipt.canceledAt)
//    }
//}
