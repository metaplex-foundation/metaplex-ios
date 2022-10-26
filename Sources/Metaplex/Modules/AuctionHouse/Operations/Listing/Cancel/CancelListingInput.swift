//
//  CancelListingInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

public struct CancelListingInput {
    let auctioneerAuthority: Account?
    let auctionHouse: Auctionhouse
    let listing: Listing
}
