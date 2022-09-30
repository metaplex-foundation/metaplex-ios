//
//  AuctionHouseProgram.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/29/22.
//

import AuctionHouse
import Foundation
import Solana

public class AuctionHouseProgram {
    static let programId = PROGRAM_ID!

    static func bidAccounts(connection: Connection) -> BidReceiptGpaBuilder {
        BidReceiptGpaBuilder(connection: connection, programId: programId)
    }
}
