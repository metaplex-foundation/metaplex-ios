//
//  AuctionHouse.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/19/22.
//

import AuctionHouse
import Foundation
import Solana

extension Auctionhouse {
    static let PROGRAM = "auction_house"

    var isNative: Bool {
        treasuryMint == PublicKey(string: "So11111111111111111111111111111111111111112")!
    }
    
    var address: PublicKey? {
        try? Auctionhouse.pda(creator: creator, treasuryMint: treasuryMint).get()
    }

    static func pda(creator: PublicKey, treasuryMint: PublicKey) -> Result<PublicKey, Error> {
        let seeds = [
            PROGRAM.bytes,
            creator.bytes,
            treasuryMint.bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map {
            return $0.0
        }
    }

    static func auctioneerPda(auctionHouse: PublicKey, auctioneerAuthority: PublicKey) -> Result<PublicKey, Error> {
        let seeds = [
            "auctioneer".bytes,
            auctionHouse.bytes,
            auctioneerAuthority.bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map { $0.0 }
    }

    static func buyerEscrowPda(auctionHouse: PublicKey, buyer: PublicKey) -> Result<Pda, Error> {
        let seeds = [
            PROGRAM.bytes,
            auctionHouse.bytes,
            buyer.bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map { Pda(publicKey: $0.0, bump: $0.1) }
    }

    static func tradeStatePda(
        auctionHouse: PublicKey,
        wallet: PublicKey,
        treasuryMint: PublicKey,
        mintAccount: PublicKey,
        buyerPrice: UInt64,
        tokenSize: UInt64,
        tokenAccount: PublicKey?
    ) -> Result<Pda, Error> {
        let tokenAccountBytes = tokenAccount?.bytes ?? []
        let seeds = [
            PROGRAM.bytes,
            wallet.bytes,
            auctionHouse.bytes,
            tokenAccountBytes,
            treasuryMint.bytes,
            mintAccount.bytes,
            buyerPrice.bytes,
            tokenSize.bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map { Pda(publicKey: $0.0, bump: $0.1) }
    }

    static func programAsSignerPda() -> Result<Pda, Error> {
        let seeds = [
            PROGRAM.bytes,
            "signer".bytes
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map { Pda(publicKey: $0.0, bump: $0.1) }
    }
}
