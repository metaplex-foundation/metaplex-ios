//
//  BuyArgs.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/13/22.
//

import AuctionHouse
import Foundation
import Solana

struct BuyArgs {
    let tradeStateBump: UInt8
    let escrowPaymentBump: UInt8
    let buyerPrice: UInt64
    let tokenSize: UInt64
}

extension BuyInstructionArgs {
    init(args: BuyArgs) {
        self.init(
            tradeStateBump: args.tradeStateBump,
            escrowPaymentBump: args.escrowPaymentBump,
            buyerPrice: args.buyerPrice,
            tokenSize: args.tokenSize
        )
    }
}

extension PublicBuyInstructionArgs {
    init(args: BuyArgs) {
        self.init(
            tradeStateBump: args.tradeStateBump,
            escrowPaymentBump: args.escrowPaymentBump,
            buyerPrice: args.buyerPrice,
            tokenSize: args.tokenSize
        )
    }
}

extension AuctioneerBuyInstructionArgs {
    init(args: BuyArgs) {
        self.init(
            tradeStateBump: args.tradeStateBump,
            escrowPaymentBump: args.escrowPaymentBump,
            buyerPrice: args.buyerPrice,
            tokenSize: args.tokenSize
        )
    }
}

extension AuctioneerPublicBuyInstructionArgs {
    init(args: BuyArgs) {
        self.init(
            tradeStateBump: args.tradeStateBump,
            escrowPaymentBump: args.escrowPaymentBump,
            buyerPrice: args.buyerPrice,
            tokenSize: args.tokenSize
        )
    }
}
