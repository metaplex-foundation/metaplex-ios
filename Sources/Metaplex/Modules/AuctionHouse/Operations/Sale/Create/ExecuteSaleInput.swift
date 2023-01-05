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

    // MARK: - Helpers

    var seller: PublicKey { listing.listingReceipt.seller }
    var buyer: PublicKey { bid.bidReceipt.buyer }
    var mintAccount: PublicKey { listing.nft.mint }

    var isPartialSale: Bool { bid.bidReceipt.tokenSize < listing.listingReceipt.tokenSize }
    var isAuctionHouseMatching: Bool { bid.bidReceipt.auctionHouse.address == listing.listingReceipt.auctionHouse.address }
    var isMintMatching: Bool { bid.nft.mint == listing.nft.mint }
    var isBidCancelled: Bool { bid.bidReceipt.canceledAt != nil }
    var isListingCancelled: Bool { listing.listingReceipt.canceledAt != nil }
    var isAuctioneerRequired: Bool { !(auctionHouse.hasAuctioneer && auctioneerAuthority != nil) }
    var isPartialSaleSupported: Bool { !(isPartialSale && auctionHouse.hasAuctioneer) }
}
