//
//  FindListingByReceiptOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation
import Solana

typealias FindListingByReceiptOperation = OperationResult<FindListingByReceiptInput, OperationError>

class FindListingByReceiptOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = FindListingByReceiptInput
    typealias O = Listing

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindListingByReceiptOperation) -> OperationResult<Listing, OperationError> {
        operation.flatMap { input in
            OperationResult<Listingreceipt, Error>.init { callback in
                Listingreceipt.fromAccountAddress(connection: self.metaplex.connection.api, address: input.address) {
                    callback($0)
                }
            }
            .mapError { OperationError.findListingByReceiptError($0) }
            .flatMap { listingReceipt in
                OperationResult<Listing, OperationError>.init { callback in
                    let lazyListing = LazyListing(auctionHouse: input.auctionHouse, listingReceipt: listingReceipt, publicKey: input.address)
                    self.metaplex.auctionHouse.loadListing(lazyListing) {
                        callback($0)
                    }
                }
            }
        }
    }
}
