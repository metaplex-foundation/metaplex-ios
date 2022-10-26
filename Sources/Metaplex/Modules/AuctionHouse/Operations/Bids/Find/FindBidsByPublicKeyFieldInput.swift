//
//  FindBidsByPublicKeyFieldInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

public enum BidPublicKeyType {
    case buyer(PublicKey)
    case metadata(PublicKey)
    case mint(PublicKey)

    var publicKey: PublicKey {
        switch self {
        case .buyer(let key):
            return key
        case .metadata(let key):
            return key
        case .mint(let key):
            return key
        }
    }
}

struct FindBidsByPublicKeyFieldInput {
    let type: BidPublicKeyType
    let auctionHouse: Auctionhouse
}
