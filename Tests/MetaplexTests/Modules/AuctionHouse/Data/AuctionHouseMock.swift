//
//  AuctionHouseMock.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/20/22.
//

import AuctionHouse
import Foundation
import Solana

struct AuctionHouseMock: AuctionhouseArgs {
    let auctionHouseDiscriminator: [UInt8] = Auctionhouse.auctionHouseDiscriminator
    let auctionHouseFeeAccount: PublicKey = PublicKey(string: "DkAScnZa6GqjXkPYPAU4kediZmR2EESHXutFzR4U6TGs")!
    let auctionHouseTreasury: PublicKey = PublicKey(string: "DebSyCbsnzMppVLt1umD4tUcJV6bSQW4z3nQVXQpWhCV")!
    let treasuryWithdrawalDestination: PublicKey = AuctionHouseTestDataProvider.creator
    let feeWithdrawalDestination: PublicKey = AuctionHouseTestDataProvider.creator
    let treasuryMint: PublicKey = AuctionHouseTestDataProvider.treasuryMint
    let authority: PublicKey = AuctionHouseTestDataProvider.creator
    let creator: PublicKey = AuctionHouseTestDataProvider.creator
    let bump: UInt8 = 253
    let treasuryBump: UInt8 = 254
    let feePayerBump: UInt8 = 252
    let sellerFeeBasisPoints: UInt16 = 200
    let requiresSignOff: Bool = false
    let canChangeSalePrice: Bool = false
    let escrowPaymentBump: UInt8 = 0
    let hasAuctioneer: Bool = false
    let auctioneerAddress: PublicKey = PublicKey.default
    let scopes: [Bool] = []
}
