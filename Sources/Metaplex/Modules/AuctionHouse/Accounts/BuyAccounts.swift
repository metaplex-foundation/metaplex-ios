//
//  BidAccounts.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/12/22.
//

import AuctionHouse
import Foundation
import Solana

struct BuyAccounts {
    let wallet: PublicKey
    let paymentAccount: PublicKey
    let transferAuthority: PublicKey
    let treasuryMint: PublicKey
    let metadata: PublicKey
    let escrowPaymentAccount: PublicKey
    let authority: PublicKey
    let auctionHouse: PublicKey
    let auctionHouseFeeAccount: PublicKey
    let buyerTradeState: PublicKey
}

extension BuyInstructionAccounts {
    init(tokenAccount: PublicKey, accounts: BuyAccounts) {
        self.init(
            wallet: accounts.wallet,
            paymentAccount: accounts.paymentAccount,
            transferAuthority: accounts.transferAuthority,
            treasuryMint: accounts.treasuryMint,
            tokenAccount: tokenAccount,
            metadata: accounts.metadata,
            escrowPaymentAccount: accounts.escrowPaymentAccount,
            authority: accounts.authority,
            auctionHouse: accounts.auctionHouse,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            buyerTradeState: accounts.buyerTradeState
        )
    }
}

extension PublicBuyInstructionAccounts {
    init(tokenAccount: PublicKey, accounts: BuyAccounts) {
        self.init(
            wallet: accounts.wallet,
            paymentAccount: accounts.paymentAccount,
            transferAuthority: accounts.transferAuthority,
            treasuryMint: accounts.treasuryMint,
            tokenAccount: tokenAccount,
            metadata: accounts.metadata,
            escrowPaymentAccount: accounts.escrowPaymentAccount,
            authority: accounts.authority,
            auctionHouse: accounts.auctionHouse,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            buyerTradeState: accounts.buyerTradeState
        )
    }
}

extension AuctioneerBuyInstructionAccounts {
    init(tokenAccount: PublicKey, auctioneerAuthority: PublicKey, ahAuctioneerPda: PublicKey, accounts: BuyAccounts) {
        self.init(
            wallet: accounts.wallet,
            paymentAccount: accounts.paymentAccount,
            transferAuthority: accounts.transferAuthority,
            treasuryMint: accounts.treasuryMint,
            tokenAccount: tokenAccount,
            metadata: accounts.metadata,
            escrowPaymentAccount: accounts.escrowPaymentAccount,
            authority: accounts.authority,
            auctioneerAuthority: auctioneerAuthority,
            auctionHouse: accounts.auctionHouse,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            buyerTradeState: accounts.buyerTradeState,
            ahAuctioneerPda: ahAuctioneerPda
        )
    }
}

extension AuctioneerPublicBuyInstructionAccounts {
    init(tokenAccount: PublicKey, auctioneerAuthority: PublicKey, ahAuctioneerPda: PublicKey, accounts: BuyAccounts) {
        self.init(
            wallet: accounts.wallet,
            paymentAccount: accounts.paymentAccount,
            transferAuthority: accounts.transferAuthority,
            treasuryMint: accounts.treasuryMint,
            tokenAccount: tokenAccount,
            metadata: accounts.metadata,
            escrowPaymentAccount: accounts.escrowPaymentAccount,
            authority: accounts.authority,
            auctioneerAuthority: auctioneerAuthority,
            auctionHouse: accounts.auctionHouse,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            buyerTradeState: accounts.buyerTradeState,
            ahAuctioneerPda: ahAuctioneerPda
        )
    }
}
