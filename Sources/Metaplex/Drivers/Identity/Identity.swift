//
//  Identity.swift
//  
//
//  Created by Arturo Jamaica on 4/8/22.
//

import Foundation
import Solana

public protocol IdentityDriver {
    var publicKey: PublicKey { get }
    func sendTransaction(serializedTransaction: String, onComplete: @escaping(Result<TransactionID, Error>) -> Void)
}

class SolanaIdentityDriver: IdentityDriver {
    private let solanaRPC: Api
    public let publicKey: PublicKey
    init(solanaRPC: Api, publicKey: PublicKey){
        self.solanaRPC = solanaRPC
        self.publicKey = publicKey
    }
    
    func sendTransaction(serializedTransaction: String, onComplete: @escaping(Result<TransactionID, Error>) -> Void){
        self.solanaRPC.sendTransaction(serializedTransaction: serializedTransaction, onComplete: onComplete)
    }
}
