//
//  FindBidByReceiptOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/27/22.
//

import AuctionHouse
import Foundation
import Solana

struct FindBidByReceiptInput {
    let address: PublicKey
    let auctionHouse: AuctionhouseArgs
}

typealias FindBidByReceiptOperation = OperationResult<FindBidByReceiptInput, OperationError>

class FindBidByReceiptOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = FindBidByReceiptInput
    typealias O = Bid

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindBidByReceiptOperation) -> OperationResult<Bid, OperationError> {
        operation.flatMap { input in
            OperationResult<Bidreceipt, Error>.init { callback in
                Bidreceipt.fromAccountAddress(connection: self.metaplex.connection.api, address: input.address) {
                    callback($0)
                }
            }
            .mapError { OperationError.findBidByReceiptError($0) }
            .flatMap { bidReceipt in
                OperationResult<Bid, OperationError>.init { callback in
                    let lazyBid = LazyBid(auctionHouse: input.auctionHouse, bidReceipt: bidReceipt, publicKey: input.address)
                    self.metaplex.auctionHouse.loadBid(lazyBid) {
                        callback($0)
                    }
                }
            }
        }
    }
}
