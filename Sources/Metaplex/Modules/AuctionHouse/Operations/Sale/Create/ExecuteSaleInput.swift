//
//  ExecuteSaleInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

struct ExecuteSaleInput {
    let bid: Bid
    let listing: Listing
    let auctionHouse: AuctionhouseArgs
    let auctioneerAuthority: Account?
    let bookkeeper: Account?
    let printReceipt: Bool

    init(
        bid: Bid,
        listing: Listing,
        auctionHouse: AuctionhouseArgs,
        auctioneerAuthority: Account? = nil,
        bookkeeper: Account? = nil,
        printReceipt: Bool = true
    ) {
        self.bid = bid
        self.listing = listing
        self.auctionHouse = auctionHouse
        self.auctioneerAuthority = auctioneerAuthority
        self.bookkeeper = bookkeeper
        self.printReceipt = printReceipt
    }
}
