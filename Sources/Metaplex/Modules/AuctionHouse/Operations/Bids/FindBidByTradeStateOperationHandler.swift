//
//  FindBidByTradeStateOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/29/22.
//

import AuctionHouse
import Foundation
import Solana

typealias FindBidByTradeStateOperation = OperationResult<PublicKey, OperationError>

class FindBidByTradeStateOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = PublicKey
    typealias O = Bid

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindBidByTradeStateOperation) -> OperationResult<Bid, OperationError> {
        operation.flatMap { address in
            OperationResult.pure(Bidreceipt.pda(tradeStateAddress: address)).flatMap { receiptAddress in
                OperationResult<Bid, Error>.init { callback in
                    self.metaplex.auctionHouse.findBidByReceipt(receiptAddress) { result in
                        callback(result.mapError { $0 })
                    }
                }
            }.mapError { OperationError.findBidByTradeStateError($0) }
        }
    }
}
