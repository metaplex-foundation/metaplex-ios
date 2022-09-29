//
//  FindNftByTokenOnChainOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/27/22.
//

import Beet
import Foundation
import Solana

typealias FindNftByTokenOperation = OperationResult<PublicKey, OperationError>

class FindNftByTokenOnChainOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = PublicKey
    typealias O = NFT

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindNftByTokenOperation) -> OperationResult<NFT, OperationError> {
        operation.flatMap { account in
            OperationResult<PublicKey, OperationError>.init { callback in
                self.metaplex.getAccountInfo(account: account, decodedTo: AccountInfo.self) { buffer in
                    switch buffer {
                    case .success(let buffer):
                        guard let mintKey = buffer.data.value?.mint else {
                            callback(.failure(OperationError.nilDataOnAccount))
                            return
                        }
                        callback(.success(mintKey))
                    case .failure(let error):
                        callback(.failure(OperationError.getAccountInfoError(error)))
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
