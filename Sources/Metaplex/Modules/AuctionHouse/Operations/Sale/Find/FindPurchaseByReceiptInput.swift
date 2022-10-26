//
//  FindPurchaseByReceiptInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

struct FindPurchaseByReceiptInput {
    let address: PublicKey
    let auctionHouse: AuctionhouseArgs
}
