//
//  AuctionHouseTestDataProvider.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/20/22.
//

import AuctionHouse
import Foundation
import Solana

struct AuctionHouseTestDataProvider {
    static let creator = PublicKey(string: "95emj1a33Ei7B6ciu7gbPm7zRMRpFGs86g5nK5NiSdEK")!
    static let treasuryMint = PublicKey(string: "So11111111111111111111111111111111111111112")!

    static let address = PublicKey(string: "5xN42RZCk7wA4GjQU2VVDhda8LBL8fAnrKZK921sybLF")!

    static let expectedPda = "5xN42RZCk7wA4GjQU2VVDhda8LBL8fAnrKZK921sybLF"
    static let expectedAuctionHouse = AuctionHouseMock()
}
