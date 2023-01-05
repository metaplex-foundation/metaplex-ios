//
//  AuctionHouseTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/20/22.
//

import AuctionHouse
import Foundation
import Solana
import XCTest

@testable import Metaplex

final class AuctionHouseTests: XCTestCase {
    func testAuctionHousePda() {
        let creator = AuctionHouseTestDataProvider.creator
        let treasuryMint = AuctionHouseTestDataProvider.treasuryMint

        let pda = try? Auctionhouse.pda(creator: creator, treasuryMint: treasuryMint).get()

        XCTAssertNotNil(pda)
        XCTAssertEqual(pda!.publicKey.base58EncodedString, AuctionHouseTestDataProvider.expectedPublicKey)
    }
}
