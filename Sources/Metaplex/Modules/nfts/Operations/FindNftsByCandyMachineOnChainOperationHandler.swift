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

let candyMachineId = PublicKey(string: "cndy3Z4yapfJBmL3ShUp5exZKqR3z33thTzeNMm2gRZ")!
class FindNftsByCandyMachineOnChainOperationHandler: OperationHandler {
    var metaplex: Metaplex
    
    typealias I = FindNftsByCandyMachineInput
    typealias O = Array<NFT?>
    
    init(metaplex: Metaplex){
        self.metaplex = metaplex
    }
    
    func handle(operation: FindNftsByCandyMachineOperation) -> OperationResult<Array<NFT?>, OperationError> {
        let candyMachinePublicKeyAndVersion: OperationResult<PublicKey, OperationError> = operation.flatMap { input in
            let candyMachine = input.candyMachine
            let version = input.version ?? 2
            if version == 2 {
                let seeds = [
                    "candy_machine".bytes,
                    candyMachine.bytes
                ].map { Data($0) }
                return OperationResult.pure(
                    PublicKey.findProgramAddress(seeds: seeds, programId: candyMachineId)
                )
                .map { $0.0 }
                .mapError{ _ in OperationError.couldNotFindPDA }
            }
            return .success(candyMachine)
        }
        
        return candyMachinePublicKeyAndVersion.flatMap {
            let operation = FindNftsByCreatorOnChainOperationHandler(metaplex: self.metaplex)
            return operation.handle(operation: FindNftsByCreatorOperation.pure(.success(
                FindNftsByCreatorInput(creator: $0, position: 1)
            )))
        }
    }
}
