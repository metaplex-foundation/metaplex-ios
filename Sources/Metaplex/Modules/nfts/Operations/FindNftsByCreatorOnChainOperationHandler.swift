//
//  FindNftsByCreatorOnChainOperationHandler.swift
//  
//
//  Created by Arturo Jamaica on 4/18/22.
//

import Foundation
import Solana

struct FindNftsByCreatorInput {
    let creator: PublicKey
    let position: Int?
}

typealias FindNftsByCreatorOperation = OperationResult<FindNftsByCreatorInput, OperationError>

class FindNftsByCreatorOnChainOperationHandler: OperationHandler {
    var metaplex: Metaplex
    var metadataV1GpaBuilder: MetadataV1GpaBuilder?
    
    typealias I = FindNftsByCreatorInput
    typealias O = Array<NFT?>
    
    init(metaplex: Metaplex){
        self.metaplex = metaplex
    }
    
    func handle(operation: FindNftsByCreatorOperation) -> OperationResult<Array<NFT?>, OperationError> {
        let publicKeys: OperationResult<[PublicKey], OperationError> = operation.flatMap { [weak self] input in
            let position = input.position ?? 1
            let creator = input.creator
            self?.metadataV1GpaBuilder = TokenMetadataProgram.metadataV1Accounts(connection: self!.metaplex.connection)
                .selectMint()
                .whereCreator(nth: position, creator: creator)
            
            return self!.metadataV1GpaBuilder!.getDataAsPublicKeys()
                .mapError { OperationError.getFindNftsByCreatorOperation($0) }
        }
        
        return publicKeys.flatMap{ publicKeys in
            let operation = FindNftsByMintListOnChainOperationHandler(metaplex: self.metaplex)
            return operation.handle(operation: FindNftsByMintListOperation.pure(.success(
                publicKeys
            )))
        }
    }
}
