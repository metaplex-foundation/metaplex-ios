//
//  FindAuctionHouseByAddressOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/19/22.
//

import AuctionHouse
import Foundation
import Solana

typealias FindAuctionHouseByAddressOperation = OperationResult<PublicKey, OperationError>

class FindAuctionHouseByAddressOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = PublicKey
    typealias O = Auctionhouse

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindAuctionHouseByAddressOperation) -> OperationResult<Auctionhouse, OperationError> {
        operation.flatMap { address in
            OperationResult<Auctionhouse, Error>.init { callback in
                Auctionhouse.fromAccountAddress(connection: self.metaplex.connection.api, address: address) {
                    callback($0)
                }
            }
            .mapError { OperationError.findAuctionHouseByAddressError($0) }
        }
    }
}
