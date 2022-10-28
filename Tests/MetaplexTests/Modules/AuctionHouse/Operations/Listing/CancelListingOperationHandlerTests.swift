//
//  CancelListingOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

import Foundation
import Solana
import XCTest

@testable import Metaplex

final class CancelListingOperationHandlerTests: XCTestCase {
    func testCancelBidOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        TestDataProvider.airDropFunds(metaplex, account: auctionHouse.auctionHouseFeeAccount)

        guard let account = HotAccount(network: .testnet),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create auction house") }

        guard let listing = ListingDataProvider.createListing(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)
        else { return XCTFail("Couldn't create listing") }

        guard let signatureStatus = ListingDataProvider.cancelListing(metaplex, auctionHouse: auctionHouse, listing: listing)
        else { return XCTFail("Couldn't cancel listing") }

        XCTAssertNotNil(signatureStatus)

        guard let address = listing.listingReceipt.receipt?.publicKey
        else { return XCTFail("Listing was created without a receipt address") }
        
        guard let canceledListing = ListingDataProvider.findListingByReceipt(metaplex, address: address, auctionHouse: auctionHouse)
        else { return XCTFail("Couldn't find listing") }

        XCTAssertNotNil(canceledListing.listingReceipt.canceledAt)
    }
}
