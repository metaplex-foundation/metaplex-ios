//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 4/11/22.
//

import Foundation
import Solana

class NftClient {
    let metaplex: Metaplex
    
    init(metaplex: Metaplex){
        self.metaplex = metaplex
    }
    
    func findNftByMint(mintKey: PublicKey, onComplete: @escaping (Result<NFT, OperationError>) -> Void) {
        let operation = FindNftByMintOnChainOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindNftByMintOperation.pure(.success(mintKey))).run {
            onComplete($0)
        }
    }
    
    func findNftByMintList(mintKeys: [PublicKey], onComplete: @escaping (Result<[NFT?], OperationError>) -> Void) {
        let operation = FindNftsByMintListOnChainOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindNftsByMintListOperation.pure(.success(
            mintKeys
        ))).run { onComplete($0) }
    }
    
    func findNftsByCreator(creator: PublicKey, position: Int? = 1, onComplete: @escaping (Result<[NFT?], OperationError>) -> Void) {
        let operation = FindNftsByCreatorOnChainOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindNftsByCreatorOperation.pure(.success(
            FindNftsByCreatorInput(
                creator: creator,
                position: position
            )))).run{ onComplete($0) }
    }
    
    func findNftsByCandyMachine(candyMachine: PublicKey, version: UInt8? = 2, onComplete: @escaping (Result<[NFT?], OperationError>) -> Void) {
        let operation = FindNftsByCandyMachineOnChainOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindNftsByCandyMachineOperation.pure(.success(
            FindNftsByCandyMachineInput(
                candyMachine: candyMachine,
                version: version
            )))).run{ onComplete($0) }
    }
}
