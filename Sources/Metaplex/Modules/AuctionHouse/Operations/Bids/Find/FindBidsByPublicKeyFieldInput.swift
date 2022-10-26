//
//  FindBidsByPublicKeyFieldInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

struct FindBidsByPublicKeyFieldInput {
    enum Field {
        case buyer, metadata, mint
    }

    let field: Field
    let auctionHouse: Auctionhouse
    let publicKey: PublicKey
}
