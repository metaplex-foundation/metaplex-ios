//
//  Connection.swift
//  
//
//  Created by Arturo Jamaica on 4/8/22.
//

import Foundation
import Solana

public protocol Connection {
    func getProgramAccounts<T: BufferLayout>(publicKey: PublicKey,
                                             decodedTo: T.Type,
                                             config: RequestConfiguration,
                                             onComplete: @escaping (Result<[ProgramAccount<T>], Error>) -> Void)
    func getAccountInfo<T>(account: PublicKey, decodedTo: T.Type, onComplete: @escaping (Result<BufferInfo<T>, Error>) -> Void)
    func getMultipleAccountsInfo<T>(accounts: [PublicKey], decodedTo: T.Type, onComplete: @escaping (Result<[BufferInfo<T>?], Error>) -> Void)
    func confirmTransaction(signature: String, configs: RequestConfiguration?, onComplete: @escaping (Result<[SignatureStatus?], Error>) -> Void)
}

public class SolanaConnectionDriver: Connection {
    public let solanaRPC: Api

    public init(endpoint: RPCEndpoint) {
        self.solanaRPC = Api(router: .init(endpoint: endpoint), supportedTokens: [])
    }

    public func getProgramAccounts<T>(publicKey: PublicKey, decodedTo: T.Type, config: RequestConfiguration, onComplete: @escaping (Result<[ProgramAccount<T>], Error>) -> Void) where T: BufferLayout {
        solanaRPC.getProgramAccounts(publicKey: publicKey.base58EncodedString, configs: config, decodedTo: decodedTo, onComplete: onComplete)
    }

    public func getAccountInfo<T>(account: PublicKey, decodedTo: T.Type, onComplete: @escaping (Result<BufferInfo<T>, Error>) -> Void) {
        solanaRPC.getAccountInfo(account: account.base58EncodedString, decodedTo: T.self, onComplete: onComplete)
    }

    public func getMultipleAccountsInfo<T>(accounts: [PublicKey], decodedTo: T.Type, onComplete: @escaping (Result<[BufferInfo<T>?], Error>) -> Void) {
        solanaRPC.getMultipleAccounts(pubkeys: accounts.map { $0.base58EncodedString }, decodedTo: T.self, onComplete: onComplete)
    }

    public func confirmTransaction(signature: String, configs: RequestConfiguration?, onComplete: @escaping (Result<[SignatureStatus?], Error>) -> Void) {
        solanaRPC.getSignatureStatuses(pubkeys: [signature], configs: configs, onComplete: onComplete)
    }
}
