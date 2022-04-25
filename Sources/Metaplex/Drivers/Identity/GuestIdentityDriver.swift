//
//  GuestIdentityDriver.swift
//  
//
//  Created by Arturo Jamaica on 4/9/22.
//

import Foundation
import Solana

class GuestIdentityDriver: IdentityDriver {
    private let solanaRPC: Api
    internal let publicKey: PublicKey
    init(solanaRPC: Api) {
        self.solanaRPC = solanaRPC
        self.publicKey = PublicKey.default
    }

    func sendTransaction(serializedTransaction: String, onComplete: @escaping(Result<TransactionID, IdentityDriverError>) -> Void) {
        self.solanaRPC.sendTransaction(serializedTransaction: serializedTransaction) { result in
            switch result {
            case .success(let transactionID):
                onComplete(.success(transactionID))
            case .failure(let error):
                onComplete(.failure(.sendTransactionError(error)))
            }
        }
    }

    func signTransaction(transaction: Transaction, onComplete: @escaping (Result<Transaction, IdentityDriverError>) -> Void) {
        onComplete(.failure(IdentityDriverError.methodNotAvailable))
    }

    func signAllTransactions(transactions: [Transaction], onComplete: @escaping (Result<[Transaction?], IdentityDriverError>) -> Void) {
        onComplete(.failure(IdentityDriverError.methodNotAvailable))
    }
}
