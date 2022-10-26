//
//  FindBidByTradeStateOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/29/22.
//

import AuctionHouse
import Foundation
import Solana

struct FindBidByTradeStateInput {
    let address: PublicKey
    let auctionHouse: AuctionhouseArgs
}

typealias FindBidByTradeStateOperation = OperationResult<FindBidByTradeStateInput, OperationError>

class FindBidByTradeStateOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = FindBidByTradeStateInput
    typealias O = Bid

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindBidByTradeStateOperation) -> OperationResult<Bid, OperationError> {
        operation.flatMap { input in
            OperationResult.pure(Bidreceipt.pda(tradeStateAddress: input.address)).flatMap { receiptAddress in
                OperationResult<Bid, Error>.init { callback in
                    self.metaplex.auctionHouse.findBidByReceipt(
                        receiptAddress.publicKey,
                        auctionHouse: input.auctionHouse
                    ) { result in
                        callback(result.mapError { $0 })
                    }
                }
            }.mapError { OperationError.findBidByTradeStateError($0) }
        }
    }
}
