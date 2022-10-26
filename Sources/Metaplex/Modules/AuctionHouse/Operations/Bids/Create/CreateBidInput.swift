//
//  CreateBidInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

struct CreateBidInput {
    let auctionHouse: AuctionhouseArgs
    let buyer: Account?
    let authority: Account?
    let auctioneerAuthority: Account?
    let mintAccount: PublicKey
    let seller: PublicKey?
    let tokenAccount: PublicKey?
    let price: UInt64?
    let tokens: UInt64?
    let printReceipt: Bool
    let bookkeeper: Account?

    init(
        auctionHouse: AuctionhouseArgs,
        buyer: Account? = nil,
        authority: Account? = nil,
        auctioneerAuthority: Account? = nil,
        mintAccount: PublicKey,
        seller: PublicKey? = nil,
        tokenAccount: PublicKey? = nil,
        price: UInt64? = 0,
        tokens: UInt64? = 1,
        printReceipt: Bool = true,
        bookkeeper: Account? = nil
    ) {
        self.auctionHouse = auctionHouse
        self.buyer = buyer
        self.authority = authority
        self.auctioneerAuthority = auctioneerAuthority
        self.mintAccount = mintAccount
        self.seller = seller
        self.tokenAccount = tokenAccount
        self.price = price
        self.tokens = tokens
        self.printReceipt = printReceipt
        self.bookkeeper = bookkeeper
    }
}
