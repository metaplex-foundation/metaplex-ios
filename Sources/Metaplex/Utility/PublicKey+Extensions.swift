//
//  PublicKey+Extensions.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Foundation
import Solana

extension PublicKey {
    static let vaultProgramId = PublicKey(string: "vau1zxA2LbssAUEF7Gpw91zMM1LvXrvpzJtmZ58rPsn")!

    static let auctionProgramId = PublicKey(string: "auctxRXPeJoc4817jDhf4HbjnhEcr1cCXenosMhK5R8")!

    static let metaplexProgramId = PublicKey(string: "p1exdMJcjVao65QdewkaZRUnU6VPSXhus9n2GzWfh98")!

    static let systemProgramID =  PublicKey(string: "11111111111111111111111111111111")!
}

extension PublicKey {
    static func findAssociatedTokenAccountPda(mint: PublicKey, owner: PublicKey) -> PublicKey? {
        try? associatedTokenAddress(walletAddress: owner, tokenMintAddress: mint).get()
    }
}

