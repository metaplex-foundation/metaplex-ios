//
//  SaleArgs.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/18/22.
//

import AuctionHouse
import Foundation
import Solana

struct SaleArgs {
    let escrowPaymentBump: UInt8
    let freeTradeStateBump: UInt8
    let programAsSignerBump: UInt8
    let buyerPrice: UInt64
    let tokenSize: UInt64
}

extension ExecuteSaleInstructionArgs {
    init(args: SaleArgs) {
        self.init(
            escrowPaymentBump: args.escrowPaymentBump,
            freeTradeStateBump: args.freeTradeStateBump,
            programAsSignerBump: args.programAsSignerBump,
            buyerPrice: args.buyerPrice,
            tokenSize: args.tokenSize
        )
    }
}

extension ExecutePartialSaleInstructionArgs {
    init(partialOrderSize: UInt64?, partialOrderPrice: UInt64?, args: SaleArgs) {
        self.init(
            escrowPaymentBump: args.escrowPaymentBump,
            freeTradeStateBump: args.freeTradeStateBump,
            programAsSignerBump: args.programAsSignerBump,
            buyerPrice: args.buyerPrice,
            tokenSize: args.tokenSize,
            partialOrderSize: partialOrderSize,
            partialOrderPrice: partialOrderPrice
        )
    }
}

extension AuctioneerExecuteSaleInstructionArgs {
    init(args: SaleArgs) {
        self.init(
            escrowPaymentBump: args.escrowPaymentBump,
            freeTradeStateBump: args.freeTradeStateBump,
            programAsSignerBump: args.programAsSignerBump,
            buyerPrice: args.buyerPrice,
            tokenSize: args.tokenSize
        )
    }
}
