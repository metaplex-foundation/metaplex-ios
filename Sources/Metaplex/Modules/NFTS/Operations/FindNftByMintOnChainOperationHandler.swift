//
//  FindNftByMintOnChainOperation.swift
//  
//
//  Created by Arturo Jamaica on 4/11/22.
//

import Foundation
import Solana

typealias FindNftByMintOperation = OperationResult<PublicKey, OperationError>

class FindNftByMintOnChainOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = PublicKey
    typealias O = NFT

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindNftByMintOperation) -> OperationResult<NFT, OperationError> {
        let bufferInfoResult: OperationResult<(BufferInfo<MetadataAccount>, BufferInfo<MasterEditionAccount>), OperationError>  = operation.flatMap { mintKey in

            let metaDataResult = OperationResult.pure(MetadataAccount.pda(mintKey: mintKey))
                .flatMap { (publicKey) in
                    OperationResult<BufferInfo<MetadataAccount>, Error>.init { cb in
                        self.metaplex.getAccountInfo(account: publicKey, decodedTo: MetadataAccount.self) {
                            cb($0)
                        }
                    }
                }
                .mapError { OperationError.getMetadataAccountInfoError($0) }

            let masterEditionResult = OperationResult.pure(MasterEditionAccount.pda(mintKey: mintKey))
                .flatMap { (publicKey) in
                    OperationResult<BufferInfo<MasterEditionAccount>, Error>.init { cb in
                        self.metaplex.getAccountInfo(account: publicKey, decodedTo: MasterEditionAccount.self) {
                            cb($0)
                        }
                    }
                }
                .mapError { OperationError.getMasterEditionAccountInfoError($0) }

            return OperationResult<(BufferInfo<MetadataAccount>, BufferInfo<MasterEditionAccount>), OperationError>
                .map2(metaDataResult, masterEditionResult) { metaDataResult, masterEditionResult in
                    return (metaDataResult, masterEditionResult)
                }
        }

        return bufferInfoResult.flatMap { buffer in
            if let metadataAccount = buffer.0.data.value, let masterEditionAccount = buffer.1.data.value {
                return OperationResult.success(NFT(metadataAccount: metadataAccount, masterEditionAccount: masterEditionAccount))
            } else {
                return .failure(OperationError.nilDataOnAccount)
            }
        }
    }
}
