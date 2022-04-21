//
//  GmaBuilder.swift
//  
//
//  Created by Arturo Jamaica on 4/18/22.
//

import Foundation
import Solana


struct GmaBuilderOptions {
    let chunkSize: Int?
}
struct MaybeAccountInfoWithPublicKey {
    public let pubkey: PublicKey
    public let exists: Bool
    public let metadata: MetadataAccount?
}

class GmaBuilder {
    private let connection: Connection
    private var publicKeys: [PublicKey]
    private let chunkSize: Int
    
    init(connection: Connection, publicKeys: [PublicKey], options: GmaBuilderOptions?){
        self.connection = connection
        self.chunkSize = options?.chunkSize ?? 100
        self.publicKeys = publicKeys
    }
    
    func setPublicKeys(publicKeys: [PublicKey]) -> GmaBuilder{
        self.publicKeys.append(contentsOf: publicKeys)
        return self
    }
    
    func get() -> OperationResult<[MaybeAccountInfoWithPublicKey], Error> {
        return self.getChunks(publicKeys: publicKeys)
    }
    
    private func getChunks( publicKeys: [PublicKey]) -> OperationResult<[MaybeAccountInfoWithPublicKey], Error> {
        return OperationResult.init { [weak self] cb in
            var results: [MaybeAccountInfoWithPublicKey] = []
            
            let chunks = publicKeys.chunked(into: self!.chunkSize)
            let chunkOperations = chunks.map { self!.getChunk(publicKeys: $0) }
            
            let dispatchGroup = DispatchGroup()
            for chunk in chunkOperations {
                dispatchGroup.enter()
                chunk.run { result in
                    switch result {
                    case .success(let publicKeys):
                        results.append(contentsOf: publicKeys)
                    case .failure(let error):
                        cb(.failure(error))
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                cb(.success(results))
            }
        }
    }
    
    private func getChunk(publicKeys: [PublicKey]) -> OperationResult<[MaybeAccountInfoWithPublicKey], Error> {
        return OperationResult { [weak self] cb in
            self?.connection.getMultipleAccountsInfo(accounts: publicKeys, decodedTo: MetadataAccount.self) { cb($0) }
        }.flatMap { accounts in
            var maybeAccounts: [MaybeAccountInfoWithPublicKey] = []
            zip(publicKeys, accounts).forEach { (publicKey, account) in
                if let account = account.data.value {
                    maybeAccounts.append(MaybeAccountInfoWithPublicKey(pubkey: publicKey, exists: true, metadata: account))
                } else {
                    maybeAccounts.append(MaybeAccountInfoWithPublicKey(pubkey: publicKey, exists: false, metadata: nil))
                }
            }
            return OperationResult.success(maybeAccounts)
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
