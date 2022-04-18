//
//  FindNftsByCandyMachineOnChainOperationHandler.swift
//  
//
//  Created by Arturo Jamaica on 4/18/22.
//

import Foundation
import Solana

struct FindNftsByCandyMachineInput {
    let candyMachine: PublicKey
    let version: UInt8?
}

typealias FindNftsByCandyMachineOperation = OperationResult<FindNftsByCandyMachineInput, OperationError>

class FindNftsByCandyMachineOnChainOperation: OperationHandler {
    var metaplex: Metaplex
    
    typealias I = FindNftsByCandyMachineInput
    typealias O = Array<NFT>
    
    init(metaplex: Metaplex){
        self.metaplex = metaplex
    }
    
    func handle(operation: FindNftsByCandyMachineOperation) -> OperationResult<Array<NFT>, OperationError> {
        fatalError("Not implemented.")
    }
}
