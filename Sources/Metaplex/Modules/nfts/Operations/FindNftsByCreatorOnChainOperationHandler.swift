//
//  FindNftsByCreatorOnChainOperationHandler.swift
//  
//
//  Created by Arturo Jamaica on 4/18/22.
//

import Foundation
import Solana

struct FindNftsByCreatorInput {
    let candyMachine: PublicKey
    let position: UInt8?
}

typealias FindNftsByCreatorOperation = OperationResult<FindNftsByCreatorInput, OperationError>

class FindNftsByCreatorOnChainOperation: OperationHandler {
    var metaplex: Metaplex
    
    typealias I = FindNftsByCreatorInput
    typealias O = Array<NFT>
    
    init(metaplex: Metaplex){
        self.metaplex = metaplex
    }
    
    func handle(operation: FindNftsByCreatorOperation) -> OperationResult<Array<NFT>, OperationError> {
        fatalError("Not implemented.")
    }
}
