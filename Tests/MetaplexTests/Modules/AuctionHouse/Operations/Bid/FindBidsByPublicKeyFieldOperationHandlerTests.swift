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

        guard let account = HotAccount(network: .testnet),
              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
        else { return XCTFail("Couldn't create auction house") }

        guard let bid1 = BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, nft: nft)?.bidReceipt
        else { return XCTFail("Couldn't create bid") }

        guard let bid2 = BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, nft: nft)?.bidReceipt
        else { return XCTFail("Couldn't create bid") }

        let buyer = HotAccount(network: .testnet)!
        TestDataProvider.airDropFunds(metaplex, account: buyer.publicKey)

//        guard let bid3 = AuctionHouseTestDataProvider.createBid(
//            metaplex, auctionHouse: auctionHouse,
//            nft: nft,
//            buyer: buyer
//        )?.bidReceipt
//        else { return XCTFail("Couldn't create bid") }

        let bids = BidDataProvider.findBidsBy(metaplex, type: .buyer(metaplex.identity().publicKey), auctionHouse: auctionHouse)

        XCTAssert(bids.count == 2)
    }
}
