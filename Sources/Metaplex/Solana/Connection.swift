//
//  Connection.swift
//  
//
//  Created by Arturo Jamaica on 4/8/22.
//

import Foundation
import Solana

public protocol Connection {
    func getAccountInfo<T>(account: String, decodedTo: T.Type, onComplete: @escaping (Result<BufferInfo<T>, Error>) -> Void)
    func getMultipleAccountsInfo<T>(accounts: [String], decodedTo: T.Type, onComplete: @escaping (Result<[BufferInfo<T>], Error>) -> Void)
    func confirmTransaction(signature: String, configs: RequestConfiguration?, onComplete: @escaping (Result<[SignatureStatus?], Error>) -> Void)
}

class SolanaConnectionDriver: Connection {
    public let solanaRPC: Api

    init(endpoint: RPCEndpoint) {
        self.solanaRPC = Api(router: .init(endpoint: endpoint), supportedTokens: [])
    }

    func getAccountInfo<T>(account: String, decodedTo: T.Type, onComplete: @escaping (Result<BufferInfo<T>, Error>) -> Void) {
        solanaRPC.getAccountInfo(account: account, decodedTo: T.self, onComplete: onComplete)
    }

    func getMultipleAccountsInfo<T>(accounts: [String], decodedTo: T.Type, onComplete: @escaping (Result<[BufferInfo<T>], Error>) -> Void) {
        solanaRPC.getMultipleAccounts(pubkeys: accounts, decodedTo: T.self, onComplete: onComplete)
    }

    func confirmTransaction(signature: String, configs: RequestConfiguration?, onComplete: @escaping (Result<[SignatureStatus?], Error>) -> Void) {
        solanaRPC.getSignatureStatuses(pubkeys: [signature], configs: configs, onComplete: onComplete)
    }
}
