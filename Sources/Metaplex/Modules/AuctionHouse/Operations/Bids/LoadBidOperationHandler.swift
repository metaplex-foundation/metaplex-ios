//
//  LoadBidOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/27/22.
//

import AuctionHouse
import Foundation
import Solana

typealias LoadBidOperation = OperationResult<Bidreceipt, OperationError>

class LoadBidOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = Bidreceipt
    typealias O = Bid

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: LoadBidOperation) -> OperationResult<Bid, OperationError> {
        operation.flatMap { bidReceipt in
            OperationResult<Bid, OperationError>.init { callback in
                if let tokenAddress = bidReceipt.tokenAddress {
                    self.metaplex.nft.findByToken(address: tokenAddress) { result in
                        switch result {
                        case .success(let nft):
                            callback(.success(Bid(bidReceipt: bidReceipt, nft: nft)))
                        case .failure(let error):
                            callback(.failure(error))
                        }
                    }
                } else {
                    self.metaplex.nft.findByMetadata(bidReceipt.metadata) { result in
                        switch result {
                        case .success(let nft):
                            callback(.success(Bid(bidReceipt: bidReceipt, nft: nft)))
                        case .failure(let error):
                            callback(.failure(error))
                        }
                    }
                }
            }
        }
    }
}
