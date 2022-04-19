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
}
