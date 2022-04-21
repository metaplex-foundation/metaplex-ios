//
//  FindNftsByOwnerOnChainOperationHandler.swift
//  
//
//  Created by Arturo Jamaica on 4/21/22.
//

import Foundation
import Solana

typealias FindNftsByOwnerOperation = OperationResult<PublicKey, OperationError>

class FindNftsByOwnerOnChainOperationHandler: OperationHandler {
    typealias I = PublicKey
    typealias O = Array<NFT?>
    
    var metaplex: Metaplex
    init(metaplex: Metaplex){
        self.metaplex = metaplex
    }
    
    func handle(operation: FindNftsByOwnerOperation) -> OperationResult<Array<NFT?>, OperationError> {
        operation.flatMap { owner in
            return TokenProgram()
                .tokenAccounts(connection: self.metaplex.connection)
                .selectMint()
                .whereOwner(owner: owner)
                .whereAmount(amount: 1)
                .getDataAsPublicKeys()
                .mapError { _ in OperationError.couldNotFindPDA }
        }.flatMap { publicKeys in
            let operation = FindNftsByMintListOnChainOperationHandler(metaplex: self.metaplex)
            return operation.handle(operation: FindNftsByMintListOperation.pure(.success(
                publicKeys
            )))
        }
    }
}
