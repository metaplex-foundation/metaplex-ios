//
//  Identity.swift
//  
//
//  Created by Arturo Jamaica on 4/8/22.
//

import Foundation
import Solana

public protocol IdentityDriver: Account {
    var publicKey: PublicKey { get }

    func sign(serializedMessage: Data) throws -> Data
    func signTransaction(
        transaction: Transaction,
        onComplete: @escaping (Result<Transaction, IdentityDriverError>) -> Void
    )
    func signAllTransactions(
        transactions: [Transaction],
        onComplete: @escaping (Result<[Transaction?], IdentityDriverError>) -> Void
    )

    func sendTransaction(
        serializedTransaction: String,
        onComplete: @escaping(Result<TransactionID, IdentityDriverError>) -> Void
    )
}

extension IdentityDriver {
    func `is`(that: IdentityDriver) -> Bool {
        return publicKey.base58EncodedString == that.publicKey.base58EncodedString
    }
}

public enum IdentityDriverError: Error {
    case methodNotAvailable
    case sendTransactionError(Error)
}

extension IdentityDriverError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .methodNotAvailable:
            return "Method not avaiable"
        case .sendTransactionError(let error):
            return "Could not send transaction with Error: (\(error.localizedDescription)"
        }
    }
}
