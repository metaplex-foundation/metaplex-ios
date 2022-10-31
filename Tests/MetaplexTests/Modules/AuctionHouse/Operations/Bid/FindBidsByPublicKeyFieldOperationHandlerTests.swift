//
//  FindBidsByPublicKeyFieldOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/25/22.
//

import Foundation
import Solana
import XCTest

@testable import Metaplex

final class FindBidsByPublicKeyFieldOperationHandlerTests: XCTestCase {
    func testFindBidsByPublicKeyFieldOperation() {
        let metaplex = TestDataProvider.createMetaplex()
        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
        else { return XCTFail("Couldn't create auction house") }

        TestDataProvider.airDropFunds(metaplex, account: auctionHouse.auctionHouseFeeAccount)

        guard let account = HotAccount(),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create auction house") }

        guard let bid1 = BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)?.bidReceipt
        else { return XCTFail("Couldn't create bid") }

        guard let bid2 = BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint, price: 100)?.bidReceipt
        else { return XCTFail("Couldn't create bid") }

        let buyer = HotAccount()!
        TestDataProvider.airDropFunds(metaplex, account: buyer.publicKey)

        guard let bid3 = BidDataProvider.createBid(
            metaplex, auctionHouse: auctionHouse,
            mintAccount: nft.mint,
            buyer: buyer,
            seller: metaplex.identity()
        )?.bidReceipt
        else { return XCTFail("Couldn't create bid") }

        let bids = BidDataProvider.findBidsBy(metaplex, type: .buyer(metaplex.identity().publicKey), auctionHouse: auctionHouse)

        XCTAssert(bids.count == 2)
    }
}
