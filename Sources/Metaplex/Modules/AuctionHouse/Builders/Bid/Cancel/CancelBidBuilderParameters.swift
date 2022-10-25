//
//  CancelBidBuilderParameters.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/25/22.
//

import AuctionHouse
import Foundation
import Solana

struct CancelBidBuilderParameters {
    let wallet: PublicKey
    let tokenAccount: PublicKey
    let mint: PublicKey
    let auctionHouseAddress: PublicKey
    let auctionHouse: AuctionhouseArgs
    let bid: Bid
    let auctioneerAuthority: Account?
}
