//
//  ExecuteSaleOperationHandlerTests.swift
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
//final class ExecuteSaleOperationHandlerTests: XCTestCase {
//    func testExecuteSaleOperation() {
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
//        let buyer = HotAccount()!
//        TestDataProvider.airDropFunds(metaplex, account: buyer.publicKey)
//
//        guard let bid = BidDataProvider.createBid(
//            metaplex,
//            auctionHouse: auctionHouse,
//            mintAccount: nft.mint,
//            buyer: buyer,
//            seller: metaplex.identity()
//        )
//        else { return XCTFail("Couldn't create bid") }
//
//        guard let purchase = PurchaseDataProvider.executeSale(metaplex, bid: bid, listing: listing, auctionHouse: auctionHouse)
//        else { return XCTFail("Couldn't execute sale") }
//
//        XCTAssertEqual(purchase.purchaseReceipt.auctionHouse.address, auctionHouse.address)
//        XCTAssertEqual(purchase.nft.mint, nft.mint)
//    }
//}
