//
//  CancelBidInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

public struct CancelBidInput {
    let auctioneerAuthority: Account?
    let auctionHouse: AuctionhouseArgs
    let bid: Bid

    init(
        auctioneerAuthority: Account? = nil,
        auctionHouse: AuctionhouseArgs,
        bid: Bid
    ) {
        self.auctioneerAuthority = auctioneerAuthority
        self.auctionHouse = auctionHouse
        self.bid = bid
    }
}
