//
//  FindBidsByPublicKeyFieldOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/25/22.
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
//final class FindBidsByPublicKeyFieldOperationHandlerTests: XCTestCase {
//    func testFindBidsByPublicKeyFieldOperation() {
//        let metaplex = TestDataProvider.createMetaplex()
//        guard let auctionHouse = AuctionHouseDataProvider.createAuctionHouse(metaplex)
//        else { return XCTFail("Couldn't create auction house") }
//
//        guard let account = HotAccount(),
//              let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account))
//        else { return XCTFail("Couldn't create nft") }
//
//        BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint)
//
//        BidDataProvider.createBid(metaplex, auctionHouse: auctionHouse, mintAccount: nft.mint, price: 100)
//
//        let buyer = HotAccount()!
//        TestDataProvider.airDropFunds(metaplex, account: buyer.publicKey)
//
//        BidDataProvider.createBid(
//            metaplex, auctionHouse: auctionHouse,
//            mintAccount: nft.mint,
//            buyer: buyer,
//            seller: metaplex.identity()
//        )
//
//        let bids = BidDataProvider.findBidsBy(metaplex, type: .buyer(metaplex.identity().publicKey), auctionHouse: auctionHouse)
//
//        XCTAssert(bids.count == 2)
//    }
//}
