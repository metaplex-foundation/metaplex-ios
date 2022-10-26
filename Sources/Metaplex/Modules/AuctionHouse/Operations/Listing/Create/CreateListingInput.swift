//
//  CreateListingInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

struct CreateListingInput {
    let auctionHouse: AuctionhouseArgs
    let seller: Account?
    let authority: Account?
    let auctioneerAuthority: Account?
    let mintAccount: PublicKey
    let tokenAccount: PublicKey?
    let price: UInt64
    let tokens: UInt64
    let printReceipt: Bool
    let bookkeeper: Account?

    init(
        auctionHouse: AuctionhouseArgs,
        seller: Account? = nil,
        authority: Account? = nil,
        auctioneerAuthority: Account? = nil,
        mintAccount: PublicKey,
        tokenAccount: PublicKey? = nil,
        price: UInt64,
        tokens: UInt64 = 1,
        printReceipt: Bool = true,
        bookkeeper: Account? = nil
    ) {
        self.auctionHouse = auctionHouse
        self.seller = seller
        self.authority = authority
        self.auctioneerAuthority = auctioneerAuthority
        self.mintAccount = mintAccount
        self.tokenAccount = tokenAccount
        self.price = price
        self.tokens = tokens
        self.printReceipt = printReceipt
        self.bookkeeper = bookkeeper
    }
}
