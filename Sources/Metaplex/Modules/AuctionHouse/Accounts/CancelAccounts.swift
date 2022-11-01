//
//  CancelAccounts.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/16/22.
//

import AuctionHouse
import Foundation
import Solana

struct CancelAccounts {
    let wallet: PublicKey
    let tokenAccount: PublicKey
    let tokenMint: PublicKey
    let authority: PublicKey
    let auctionHouse: PublicKey
    let auctionHouseFeeAccount: PublicKey
    let tradeState: PublicKey
}

extension CancelInstructionAccounts {
    init(accounts: CancelAccounts) {
        self.init(
            wallet: accounts.wallet,
            tokenAccount: accounts.tokenAccount,
            tokenMint: accounts.tokenMint,
            authority: accounts.authority,
            auctionHouse: accounts.auctionHouse,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            tradeState: accounts.tradeState,
            tokenProgram: nil
        )
    }
}

extension AuctioneerCancelInstructionAccounts {
    init(auctioneerAuthority: PublicKey, ahAuctioneerPda: PublicKey, accounts: CancelAccounts) {
        self.init(
            wallet: accounts.wallet,
            tokenAccount: accounts.tokenAccount,
            tokenMint: accounts.tokenMint,
            authority: accounts.authority,
            auctioneerAuthority: auctioneerAuthority,
            auctionHouse: accounts.auctionHouse,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            tradeState: accounts.tradeState,
            ahAuctioneerPda: ahAuctioneerPda,
            tokenProgram: nil
        )
    }
}
