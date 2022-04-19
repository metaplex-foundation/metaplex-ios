//
//  FindNftsByMintListOnChainOperationHandler.swift
//  
//
//  Created by Arturo Jamaica on 4/18/22.
//

import Foundation
import Solana

typealias FindNftsByMintListOperation = OperationResult<Array<PublicKey>, OperationError>

class FindNftsByMintListOnChainOperationHandler: OperationHandler {
    
    var metaplex: Metaplex
    private let gmaBuilder: GmaBuilder
    
    typealias I = Array<PublicKey>
    typealias O = Array<NFT?>
    
    init(metaplex: Metaplex){
        self.metaplex = metaplex
        self.gmaBuilder = GmaBuilder(connection: self.metaplex.connection, publicKeys: [], options: nil)
    }
    
    func handle(operation: FindNftsByMintListOperation) -> OperationResult<Array<NFT?>, OperationError> {
        
        let result: OperationResult<[PublicKey], OperationError> = operation.flatMap { mintKeys in
            var pdas: [PublicKey] = []
            for mintKey in mintKeys {
                guard let pda: PublicKey = try? MetadataAccount.pda(mintKey: mintKey).get() else {
                    return .failure(OperationError.couldNotFindPDA)
                }
                pdas.append(pda)
            }
            return .pure(.success(pdas))
        }
        
        let resultAccounts: OperationResult<[MaybeAccountInfoWithPublicKey], OperationError> = result.flatMap { publicKeys in
            self.gmaBuilder.setPublicKeys(publicKeys: publicKeys)
                .get()
                .mapError {  OperationError.gmaBuilderError($0) }
        }
        
        return resultAccounts.flatMap { accountInfos in
            var nfts: [NFT?] = []
            for accountInfo in accountInfos {
                if accountInfo.exists, let metadataAccount = accountInfo.metadata{
                    nfts.append(NFT(metadataAccount: metadataAccount, masterEditionAccount: nil))
                } else {
                    nfts.append(nil)
                }
            }
            return OperationResult<Array<NFT?>, OperationError>.success(nfts)
        }
    }
}
