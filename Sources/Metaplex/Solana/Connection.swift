//
//  Connection.swift
//  
//
//  Created by Arturo Jamaica on 4/8/22.
//

import Foundation
import Solana

public protocol Connection {
    func getAccountInfo(account: String, onComplete: @escaping (Result<BufferInfo<AccountInfo>, Error>) -> Void)
    func confirmTransaction(signature: String, configs: RequestConfiguration?, onComplete: @escaping (Result<[SignatureStatus?], Error>) -> Void)
    func getMultipleAccountsInfo(accounts: [String], onComplete: @escaping (Result<[BufferInfo<AccountInfo>], Error>) -> Void)
}

class SolanaConnectionDriver: Connection {
    public let solanaRPC: Api
    
    init(endpoint: RPCEndpoint){
        self.solanaRPC = Api(router: .init(endpoint: endpoint), supportedTokens: [])
    }
    
    func getAccountInfo(account: String, onComplete: @escaping (Result<BufferInfo<AccountInfo>, Error>) -> Void) {
        solanaRPC.getAccountInfo(account: account, decodedTo: AccountInfo.self, onComplete: onComplete)
    }
    
    func getMultipleAccountsInfo(accounts: [String], onComplete: @escaping (Result<[BufferInfo<AccountInfo>], Error>) -> Void) {
        solanaRPC.getMultipleAccounts(pubkeys: accounts, decodedTo: AccountInfo.self, onComplete: onComplete)
    }
    
    func confirmTransaction(signature: String, configs: RequestConfiguration?, onComplete: @escaping (Result<[SignatureStatus?], Error>) -> Void) {
        solanaRPC.getSignatureStatuses(pubkeys: [signature], configs: configs, onComplete: onComplete)
    }
}
