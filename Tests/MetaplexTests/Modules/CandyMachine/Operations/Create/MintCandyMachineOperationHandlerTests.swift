//
//  MintCandyMachineOperationHandlerTests.swift
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

import Foundation
import XCTest

@testable import Metaplex

final class MintCandyMachineOperationTests: XCTestCase {
    func testMintCandyMachineOperation() {
        let metaplex = TestDataProvider.createMetaplex()

        guard let candyMachine = CandyMachineDataProvider.create(metaplex)
        else { return XCTFail("Couldn't create Candy Machine") }

        guard let nft = CandyMachineDataProvider.mintCandyMachine(metaplex, candyMachine: candyMachine)
        else { return XCTFail("Couldn't mint NFT") }

        guard let expectedNft = TestDataProvider.findNft(metaplex, mint: nft.mint)
        else { return XCTFail("Couldn't find minted NFT") }

        XCTAssertEqual(nft.mint, expectedNft.mint)
        XCTAssertEqual(nft.name, expectedNft.name)
        XCTAssertEqual(nft.symbol, expectedNft.symbol)
        XCTAssertEqual(nft.uri, expectedNft.uri)
        XCTAssertEqual(nft.sellerFeeBasisPoints, expectedNft.sellerFeeBasisPoints)
        XCTAssertEqual(nft.creators.count, expectedNft.creators.count)
        XCTAssertEqual(nft.primarySaleHappened, expectedNft.primarySaleHappened)
        XCTAssertEqual(nft.isMutable, expectedNft.isMutable)
    }
}
