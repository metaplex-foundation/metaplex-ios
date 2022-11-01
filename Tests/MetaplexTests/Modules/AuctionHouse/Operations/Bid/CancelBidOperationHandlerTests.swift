//
//  CancelBidOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/25/22.
//

//import Foundation
//import Solana
//import XCTest
//
//@testable import Metaplex
//
//final class CancelBidOperationHandlerTests: XCTestCase {
//    func testCancelBidOperation() {
//        let metaplex = TestDataProvider.createMetaplex()
//        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
//        else { return XCTFail("Couldn't create auction house") }
//
//        guard let account = HotAccount(),
//              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
//        else { return XCTFail("Couldn't create nft") }
//
//        guard let bid = BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)
//        else { return XCTFail("Couldn't create bid") }
//
//        guard let signatureStatus = BidDataProvider.cancelBid(metaplex, auctionHouse: auctionHouse, bid: bid)
//        else { return XCTFail("Couldn't cancel bid") }
//
//        XCTAssertNotNil(signatureStatus)
//
//        let address = bid.bidReceipt.tradeState.publicKey
//        guard let canceledBid = BidDataProvider.findBidByTradeState(metaplex, address: address, auctionHouse: auctionHouse)
//        else { return XCTFail("Couldn't find bid") }
//
//        XCTAssertNotNil(canceledBid.bidReceipt.canceledAt)
//    }
//}
