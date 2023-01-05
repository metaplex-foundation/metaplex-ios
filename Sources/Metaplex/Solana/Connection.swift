//
//  Connection.swift
//  
//
//  Created by Arturo Jamaica on 4/8/22.
//

import Foundation
import Solana

public protocol Connection {
    var api: Api { get }
    
    func getProgramAccounts<T: BufferLayout>(publicKey: PublicKey,
                                             decodedTo: T.Type,
                                             config: RequestConfiguration,
                                             onComplete: @escaping (Result<[ProgramAccount<T>], Error>) -> Void)
    func getProgramAccounts(publicKey: PublicKey,
                            config: RequestConfiguration,
                            onComplete: @escaping (Result<[ProgramAccountPureData], Error>) -> Void)
    func getAccountInfo<T>(account: PublicKey, decodedTo: T.Type, onComplete: @escaping (Result<BufferInfo<T>, Error>) -> Void)
    func getMultipleAccountsInfo<T>(
        accounts: [PublicKey],
        decodedTo: T.Type,
        onComplete: @escaping (Result<[BufferInfo<T>?], Error>) -> Void
    )
    func getCreatingTokenAccountFee(onComplete: @escaping (Result<UInt64, Error>) -> Void)
    func getCreatingTokenAccountFee(space: UInt64, onComplete: @escaping (Result<UInt64, Error>) -> Void)
    func createTokenAccount(
        mintAddress: String,
        payer: Account,
        onComplete: @escaping ((Result<(signature: String, newPubkey: String), Error>) -> Void)
    )
    func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String?,
        signers: [Account],
        onComplete: @escaping ((Result<String, Error>) -> Void)
    )
    func confirmTransaction(
        signature: String,
        configs: RequestConfiguration?,
        onComplete: @escaping (Result<[SignatureStatus?], Error>) -> Void
    )
}

public class SolanaConnectionDriver: Connection {
    @available(*, deprecated)
    public var solanaRPC: Api {
        api
    }

    public let api: Api
    public let action: Action

    public init(endpoint: RPCEndpoint) {
        let router = NetworkingRouter(endpoint: endpoint)
        self.api = Api(router: router, supportedTokens: [])
        self.action = Action(api: api, router: router, supportedTokens: [])
    }

    public func getProgramAccounts<T>(publicKey: PublicKey, decodedTo: T.Type, config: RequestConfiguration, onComplete: @escaping (Result<[ProgramAccount<T>], Error>) -> Void) where T: BufferLayout {
        api.getProgramAccounts(publicKey: publicKey.base58EncodedString, configs: config, decodedTo: decodedTo, onComplete: onComplete)
    }

    public func getProgramAccounts(publicKey: PublicKey,
                            config: RequestConfiguration,
                            onComplete: @escaping (Result<[ProgramAccountPureData], Error>) -> Void) {
        api.getProgramAccounts(publicKey: publicKey.base58EncodedString, configs: config, onComplete: onComplete)
    }

    public func getAccountInfo<T>(account: PublicKey, decodedTo: T.Type, onComplete: @escaping (Result<BufferInfo<T>, Error>) -> Void) {
        api.getAccountInfo(account: account.base58EncodedString, decodedTo: T.self, onComplete: onComplete)
    }

    public func getMultipleAccountsInfo<T>(accounts: [PublicKey], decodedTo: T.Type, onComplete: @escaping (Result<[BufferInfo<T>?], Error>) -> Void) {
        api.getMultipleAccounts(pubkeys: accounts.map { $0.base58EncodedString }, decodedTo: T.self, onComplete: onComplete)
    }

    public func getCreatingTokenAccountFee(onComplete: @escaping (Result<UInt64, Error>) -> Void) {
        getCreatingTokenAccountFee(space: ACCOUNT_SIZE, onComplete: onComplete)
    }

    public func getCreatingTokenAccountFee(
        space: UInt64,
        onComplete: @escaping (Result<UInt64, Error>) -> Void
    ) {
        api.getMinimumBalanceForRentExemption(dataLength: space, onComplete: onComplete)
    }

    public func createTokenAccount(
        mintAddress: String,
        payer: Account,
        onComplete: @escaping ((Result<(signature: String, newPubkey: String), Error>) -> Void)
    ) {
        action.createTokenAccount(mintAddress: mintAddress, payer: payer, onComplete: onComplete)
    }

    public func serializeTransaction(
        instructions: [TransactionInstruction],
        recentBlockhash: String? = nil,
        signers: [Account],
        onComplete: @escaping ((Result<String, Error>) -> Void)
    ) {
        action.serializeTransaction(instructions: instructions, recentBlockhash: recentBlockhash, signers: signers, onComplete: onComplete)
    }

    public func confirmTransaction(signature: String, configs: RequestConfiguration?, onComplete: @escaping (Result<[SignatureStatus?], Error>) -> Void) {
        api.getSignatureStatuses(pubkeys: [signature], configs: configs, onComplete: onComplete)
    }
}
