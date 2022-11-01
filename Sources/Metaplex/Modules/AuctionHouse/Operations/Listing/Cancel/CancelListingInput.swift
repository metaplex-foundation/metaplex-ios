//
//  CancelListingInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

struct CancelListingInput {
    let auctioneerAuthority: Account?
    let auctionHouse: AuctionhouseArgs
    let listing: Listing

    init(
        auctioneerAuthority: Account? = nil,
        auctionHouse: AuctionhouseArgs,
        listing: Listing
    ) {
        self.auctioneerAuthority = auctioneerAuthority
        self.auctionHouse = auctionHouse
        self.listing = listing
    }
}
