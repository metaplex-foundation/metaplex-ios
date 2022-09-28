//
//  Bid.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/27/22.
//

import AuctionHouse
import Foundation
import Solana

struct Bid {
    let bidReceipt: Bidreceipt
    let nft: NFT
}

extension Bidreceipt {
    var tokenAddress: PublicKey? {
        switch tokenAccount {
        case .some(let publicKey):
            return publicKey
        case .none:
            return nil
        }
    }
}
