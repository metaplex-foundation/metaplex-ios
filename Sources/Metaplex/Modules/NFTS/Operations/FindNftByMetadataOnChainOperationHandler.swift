//
//  FindNftByMetadataOnChainOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/28/22.
//

import Beet
import Foundation
import Solana

typealias FindNftByMetadataOperation = OperationResult<PublicKey, OperationError>

class FindNftByMetadataOnChainOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = PublicKey
    typealias O = NFT

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindNftByMetadataOperation) -> OperationResult<NFT, OperationError> {
        operation.flatMap { metadata in
            OperationResult<PublicKey, OperationError>.init { callback in
                self.metaplex.getAccountInfo(account: metadata, decodedTo: MetadataAccount.self) { result in
                    switch result {
                    case .success(let buffer):
                        guard let mintKey = buffer.data.value?.mint else {
                            callback(.failure(OperationError.nilDataOnAccount))
                            return
                        }
                        callback(.success(mintKey))
                    case .failure(let error):
                        callback(.failure(OperationError.getMetadataAccountInfoError(error)))
                    }
                }
            }
            .flatMap { mintKey in
                OperationResult<NFT, OperationError>.init { callback in
                    self.metaplex.nft.findByMint(mintKey: mintKey) {
                        callback($0)
                    }
                }
            }
        }
    }
}
