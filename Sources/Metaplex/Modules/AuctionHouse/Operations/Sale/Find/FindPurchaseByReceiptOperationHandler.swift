//
//  FindPurchaseByReceiptOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/18/22.
//

import AuctionHouse
import Foundation
import Solana

typealias FindPurchaseByReceiptOperation = OperationResult<FindPurchaseByReceiptInput, OperationError>

class FindPurchaseByReceiptOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = FindPurchaseByReceiptInput
    typealias O = Purchase

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindPurchaseByReceiptOperation) -> OperationResult<Purchase, OperationError> {
        operation.flatMap { input in
            OperationResult<Purchasereceipt, Error>.init { callback in
                Purchasereceipt.fromAccountAddress(connection: self.metaplex.connection.api, address: input.address) {
                    callback($0)
                }
            }
            .mapError { OperationError.findPurchaseByReceiptError($0) }
            .flatMap { purchaseReceipt in
                OperationResult<Purchase, OperationError>.init { callback in
                    let lazyPurchase = LazyPurchase(auctionHouse: input.auctionHouse, purchaseReceipt: purchaseReceipt, publicKey: input.address)
                    self.metaplex.auctionHouse.loadPurchase(lazyPurchase) {
                        callback($0)
                    }
                }
            }
        }
    }
}
