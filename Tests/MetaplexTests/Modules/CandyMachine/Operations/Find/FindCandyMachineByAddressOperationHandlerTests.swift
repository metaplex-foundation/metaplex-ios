//
//  FindCandyMachineByAddressOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/14/22.
//
/// All Auction House tests are set to run locally using `amman`, but are commented out so CI can pass. To run these tests you will need the [js sdk](git@github.com:metaplex-foundation/js.git). With the repo cloned, from the terminal run the following commands from the `js` directory:
///
/// ```
/// yarn install
/// yarn amman:start
/// ```

//import Foundation
//import XCTest
//
//@testable import Metaplex
//
//final class FindCandyMachineByAddressOperationTests: XCTestCase {
//    func testFindCandyMachineOperation() {
//        let metaplex = TestDataProvider.createMetaplex()
//
//        guard let candyMachine = CandyMachineDataProvider.create(metaplex)
//        else { return XCTFail("Couldn't create Candy Machine") }
//
//        guard let expectedCandyMachine = CandyMachineDataProvider.findCandyMachineByAddress(metaplex, address: candyMachine.address)
//        else { return XCTFail("Coudln't find Candy Machine") }
//
//        XCTAssertEqual(candyMachine.address, expectedCandyMachine.address)
//        XCTAssertEqual(candyMachine.authority, expectedCandyMachine.authority)
//        XCTAssertEqual(candyMachine.wallet, expectedCandyMachine.wallet)
//        XCTAssertEqual(candyMachine.tokenMint, expectedCandyMachine.tokenMint)
//        XCTAssertEqual(candyMachine.collectionMint, expectedCandyMachine.collectionMint)
//        XCTAssertEqual(candyMachine.price, expectedCandyMachine.price)
//        XCTAssertEqual(candyMachine.symbol, expectedCandyMachine.symbol)
//        XCTAssertEqual(candyMachine.sellerFeeBasisPoints, expectedCandyMachine.sellerFeeBasisPoints)
//        XCTAssertEqual(candyMachine.isMutable, expectedCandyMachine.isMutable)
//        XCTAssertEqual(candyMachine.retainAuthority, expectedCandyMachine.retainAuthority)
//        XCTAssertEqual(candyMachine.goLiveDate, expectedCandyMachine.goLiveDate)
//        XCTAssertEqual(candyMachine.maxEditionSupply, expectedCandyMachine.maxEditionSupply)
//        XCTAssertEqual(candyMachine.itemsAvailable, expectedCandyMachine.itemsAvailable)
//        XCTAssertEqual(candyMachine.endSettings != nil, expectedCandyMachine.endSettings != nil)
//        XCTAssertEqual(candyMachine.hiddenSettings != nil, expectedCandyMachine.hiddenSettings != nil)
//        XCTAssertEqual(candyMachine.whitelistMintSettings != nil, expectedCandyMachine.whitelistMintSettings != nil)
//        XCTAssertEqual(candyMachine.gatekeeper != nil, expectedCandyMachine.gatekeeper != nil)
//        XCTAssertEqual(candyMachine.creators.count, expectedCandyMachine.creators.count)
//    }
//}
