//
//  LoadPurchaseOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/18/22.
//

import Foundation
import Solana

typealias LoadPurchaseOperation = OperationResult<LazyPurchase, OperationError>

class LoadPurchaseOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = LazyPurchase
    typealias O = Purchase

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: LoadPurchaseOperation) -> OperationResult<Purchase, OperationError> {
        operation.flatMap { lazyPurchase in
            OperationResult<Purchase, OperationError>.init { callback in
                self.metaplex.nft.findByMetadata(lazyPurchase.metadata) { result in
                    switch result {
                    case .success(let nft):
                        callback(.success(Purchase(purchaseReceipt: lazyPurchase, nft: nft)))
                    case .failure(let error):
                        callback(.failure(error))
                    }
                }
            }
        }
    }
}
