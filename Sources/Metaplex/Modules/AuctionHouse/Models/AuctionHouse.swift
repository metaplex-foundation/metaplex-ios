//
//  AuctionHouse.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/19/22.
//

import AuctionHouse
import Foundation
import Solana

extension Auctionhouse {
    static func pda(creator: PublicKey, treasuryMint: PublicKey) -> Result<PublicKey, Error> {
        let seeds = [
            "aution_house".bytes,
            creator.bytes,
            treasuryMint.bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map {
            return $0.0
        }
    }
}
