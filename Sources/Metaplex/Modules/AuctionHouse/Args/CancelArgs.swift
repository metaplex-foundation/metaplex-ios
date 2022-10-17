//
//  CancelArgs.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/16/22.
//

import AuctionHouse
import Foundation
import Solana

struct CancelArgs {
    let buyerPrice: UInt64
    let tokenSize: UInt64
}

extension CancelInstructionArgs {
    init(args: CancelArgs) {
        self.init(buyerPrice: args.buyerPrice, tokenSize: args.tokenSize)
    }
}

extension AuctioneerCancelInstructionArgs {
    init(args: CancelArgs) {
        self.init(buyerPrice: args.buyerPrice, tokenSize: args.tokenSize)
    }
}
