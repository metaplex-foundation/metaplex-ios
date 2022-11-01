//
//  SellArgs.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation

struct SellArgs {
    let tradeStateBump: UInt8
    let freeTradeStateBump: UInt8
    let programAsSignerBump: UInt8
    let tokenSize: UInt64
}

extension SellInstructionArgs {
    init(buyerPrice: UInt64, args: SellArgs) {
        self.init(
            tradeStateBump: args.tradeStateBump,
            freeTradeStateBump: args.freeTradeStateBump,
            programAsSignerBump: args.programAsSignerBump,
            buyerPrice: buyerPrice,
            tokenSize: args.tokenSize
        )
    }
}

extension AuctioneerSellInstructionArgs {
    init(args: SellArgs) {
        self.init(
            tradeStateBump: args.tradeStateBump,
            freeTradeStateBump: args.freeTradeStateBump,
            programAsSignerBump: args.programAsSignerBump,
            tokenSize: args.tokenSize
        )
    }
}
