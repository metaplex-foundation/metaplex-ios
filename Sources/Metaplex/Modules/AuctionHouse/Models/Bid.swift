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

    static func pda(tradeStateAddress: PublicKey) -> Result<PublicKey, Error> {
        let seeds = [
            "bid_receipt".bytes,
            tradeStateAddress.bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map {
            return $0.0
        }
    }
}
