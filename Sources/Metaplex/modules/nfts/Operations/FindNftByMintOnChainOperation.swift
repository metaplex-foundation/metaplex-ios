//
//  FindNftByMintOnChainOperation.swift
//  
//
//  Created by Arturo Jamaica on 4/11/22.
//

import Foundation
import Solana

typealias FindNftByMintOperation = OperationResult<PublicKey, OperationError>

extension PublicKey {
    static let metadataProgramId =
    PublicKey(string: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s")!
    
    static let vaultProgramId = PublicKey(string:                                          "vau1zxA2LbssAUEF7Gpw91zMM1LvXrvpzJtmZ58rPsn")!
    
    static let auctionProgramId = PublicKey(string:                                             "auctxRXPeJoc4817jDhf4HbjnhEcr1cCXenosMhK5R8")!
    
    static let metaplexProgramId = PublicKey(string:                                                 "p1exdMJcjVao65QdewkaZRUnU6VPSXhus9n2GzWfh98")!
    
    static let systemProgramID =  PublicKey(string: "11111111111111111111111111111111")!
}

extension String {
    static let metadataPrefix = "metadata"
    static let editionKeyword = "edition"
}

class FindNftByMintOnChainOperation: OperationHandler {
    var metaplex: Metaplex
    
    typealias I = PublicKey
    typealias O = NFT
    
    init(metaplex: Metaplex){
        self.metaplex = metaplex
    }
    
    
    func handle(operation: FindNftByMintOperation) -> OperationResult<NFT, OperationError> {
        let bufferInfoResult: OperationResult<BufferInfo<NFT>, OperationError>  = operation.flatMap { mintKey in
            let seedMetadata = [String.metadataPrefix.bytes,
                                PublicKey.metadataProgramId.bytes,
                                mintKey.bytes].map { Data($0) }
            
            return OperationResult.pure(PublicKey.findProgramAddress(seeds: seedMetadata, programId: .metadataProgramId))
                .flatMap { (publicKey, nonce) in
                    OperationResult<BufferInfo<NFT>, Error>.init { cb in
                        self.metaplex.getAccountInfo(account: publicKey.base58EncodedString, decodedTo: NFT.self) {
                            cb($0)
                        }
                    }
                }
                .mapError{ .getAccountInfoError($0) }
        }
        
        return bufferInfoResult.flatMap { buffer in
            if let nft = buffer.data.value {
                return OperationResult.success(nft)
            } else {
                return OperationResult.failure(OperationError.other)
            }
        }
    }
}
