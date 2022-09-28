//
//  FindBidByReceiptOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/27/22.
//

import AuctionHouse
import Foundation
import Solana

typealias FindBidByReceiptOperation = OperationResult<PublicKey, OperationError>

class FindBidByReceiptOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = PublicKey
    typealias O = Bid

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindBidByReceiptOperation) -> OperationResult<Bid, OperationError> {
        operation.flatMap { address in
            OperationResult<Bidreceipt, Error>.init { callback in
                Bidreceipt.fromAccountAddress(connection: self.metaplex.connection.api, address: address) {
                    callback($0)
                }
            }
            .mapError { OperationError.findBidByReceiptError($0) }
            .flatMap { bidReceipt in
                OperationResult<Bid, OperationError>.init { callback in
                    self.metaplex.auctionHouse.loadBid(bidReceipt) {
                        callback($0)
                    }
                }
            }
        }
    }
}
