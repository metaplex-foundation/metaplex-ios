//
//  SellAccounts.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation
import Solana

struct SellAccounts {
    let wallet: PublicKey
    let tokenAccount: PublicKey
    let metadata: PublicKey
    let authority: PublicKey
    let auctionHouse: PublicKey
    let auctionHouseFeeAccount: PublicKey
    let sellerTradeState: PublicKey
    let freeSellerTradeState: PublicKey
    let programAsSigner: PublicKey
}

extension SellInstructionAccounts {
    init(accounts: SellAccounts) {
        self.init(
            wallet: accounts.wallet,
            tokenAccount: accounts.tokenAccount,
            metadata: accounts.metadata,
            authority: accounts.authority,
            auctionHouse: accounts.auctionHouse,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            sellerTradeState: accounts.sellerTradeState,
            freeSellerTradeState: accounts.freeSellerTradeState,
            programAsSigner: accounts.programAsSigner
        )
    }
}

extension AuctioneerSellInstructionAccounts {
    init(auctioneerAuthority: PublicKey, auctioneerPda: PublicKey, accounts: SellAccounts) {
        self.init(
            wallet: accounts.wallet,
            tokenAccount: accounts.tokenAccount,
            metadata: accounts.metadata,
            authority: accounts.authority,
            auctioneerAuthority: auctioneerAuthority,
            auctionHouse: accounts.auctionHouse,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            sellerTradeState: accounts.sellerTradeState,
            freeSellerTradeState: accounts.freeSellerTradeState,
            ahAuctioneerPda: auctioneerPda,
            programAsSigner: accounts.programAsSigner
        )
    }
}
