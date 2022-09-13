//
//  MetaplexTokenStandard.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Foundation
import Solana

public enum MetaplexTokenStandard: UInt8, Codable {
    case NonFungible = 0, FungibleAsset = 1, Fungible = 2, NonFungibleEdition = 3
}
