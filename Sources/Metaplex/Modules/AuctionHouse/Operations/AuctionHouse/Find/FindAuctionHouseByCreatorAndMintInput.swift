//
//  FindAuctionHouseByCreatorAndMintInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import Foundation
import Solana

public struct FindAuctionHouseByCreatorAndMintInput {
    let creator: PublicKey
    let treasuryMint: PublicKey
}
