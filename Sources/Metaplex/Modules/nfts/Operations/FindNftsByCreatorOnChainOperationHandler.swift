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

typealias FindNftsByCreatorOnChainOperation = OperationResult<FindNftsByCreatorInput, OperationError>

class FindNftsByCreatorOnChainOperationHandler: OperationHandler {    
    var metaplex: Metaplex
    
    typealias I = FindNftsByCreatorInput
    typealias O = Array<NFT>
    
    init(metaplex: Metaplex){
        self.metaplex = metaplex
    }
    
    func handle(operation: FindNftsByCreatorOnChainOperation) -> OperationResult<Array<NFT>, OperationError> {
        fatalError("Not implemented.")
    }
}
