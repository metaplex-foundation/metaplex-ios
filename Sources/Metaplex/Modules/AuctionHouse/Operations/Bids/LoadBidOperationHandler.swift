//
//  LoadBidOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/27/22.
//

import Foundation
import Solana

typealias LoadBidOperation = OperationResult<LazyBid, OperationError>

class LoadBidOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = LazyBid
    typealias O = Bid

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: LoadBidOperation) -> OperationResult<Bid, OperationError> {
        operation.flatMap { lazyBid in
            OperationResult<Bid, OperationError>.init { callback in
                if let tokenAddress = lazyBid.tokenAddress {
                    self.metaplex.nft.findByToken(address: tokenAddress) { result in
                        switch result {
                        case .success(let nft):
                            callback(.success(Bid(bidReceipt: lazyBid, nft: nft)))
                        case .failure(let error):
                            callback(.failure(error))
                        }
                    }
                } else {
                    self.metaplex.nft.findByMetadata(lazyBid.metadata) { result in
                        switch result {
                        case .success(let nft):
                            callback(.success(Bid(bidReceipt: lazyBid, nft: nft)))
                        case .failure(let error):
                            callback(.failure(error))
                        }
                    }
                }
            }
        }
    }
}
