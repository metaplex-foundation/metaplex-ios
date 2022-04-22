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
    private var tokenGpaBuilder: TokenGpaBuilder?
    
    var metaplex: Metaplex
    init(metaplex: Metaplex){
        self.metaplex = metaplex
    }
    
    func handle(operation: FindNftsByOwnerOperation) -> OperationResult<Array<NFT?>, OperationError> {
        operation.flatMap { owner in
            self.tokenGpaBuilder = TokenProgram
                .tokenAccounts(connection: self.metaplex.connection)
            
            return self.tokenGpaBuilder!
                .selectMint()
                .whereOwner(owner: owner)
                .whereAmount(amount: 1)
                .getDataAsPublicKeys()
                .mapError { OperationError.getFindNftsByOwnerOperation($0) }
        }.flatMap { (publicKeys: [PublicKey]) in
            let operation = FindNftsByMintListOnChainOperationHandler(metaplex: self.metaplex)
            return operation.handle(operation: FindNftsByMintListOperation.pure(.success(
                publicKeys
            )))
        }
    }
}
