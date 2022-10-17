//
//  LoadListingOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import Foundation
import Solana

typealias LoadListingOperation = OperationResult<LazyListing, OperationError>

class LoadListingOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = LazyListing
    typealias O = Listing

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: LoadListingOperation) -> OperationResult<Listing, OperationError> {
        operation.flatMap { lazyListing in
            OperationResult<Listing, OperationError>.init { callback in
                self.metaplex.nft.findByMetadata(lazyListing.metadata) { result in
                    switch result {
                    case .success(let nft):
                        callback(.success(Listing(listingReceipt: lazyListing, nft: nft)))
                    case .failure(let error):
                        callback(.failure(error))
                    }
                }
            }
        }
    }
}
