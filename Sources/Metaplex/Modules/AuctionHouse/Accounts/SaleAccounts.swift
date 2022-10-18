//
//  SaleAccounts.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/18/22.
//

import AuctionHouse
import Foundation
import Solana

struct SaleAccounts {
    let buyer: PublicKey
    let seller: PublicKey
    let tokenAccount: PublicKey
    let tokenMint: PublicKey
    let metadata: PublicKey
    let treasuryMint: PublicKey
    let escrowPaymentAccount: PublicKey
    let sellerPaymentReceiptAccount: PublicKey
    let buyerReceiptTokenAccount: PublicKey
    let authority: PublicKey
    let auctionHouseAddress: PublicKey
    let auctionHouseFeeAccount: PublicKey
    let auctionHouseTreasury: PublicKey
    let buyerTradeState: PublicKey
    let sellerTradeState: PublicKey
    let freeTradeState: PublicKey
    let programAsSigner: PublicKey
}

extension ExecuteSaleInstructionAccounts {
    init(accounts: SaleAccounts) {
        self.init(
            buyer: accounts.buyer,
            seller: accounts.seller,
            tokenAccount: accounts.tokenAccount,
            tokenMint: accounts.tokenMint,
            metadata: accounts.metadata,
            treasuryMint: accounts.treasuryMint,
            escrowPaymentAccount: accounts.escrowPaymentAccount,
            sellerPaymentReceiptAccount: accounts.sellerPaymentReceiptAccount,
            buyerReceiptTokenAccount: accounts.buyerReceiptTokenAccount,
            authority: accounts.authority,
            auctionHouse: accounts.auctionHouseAddress,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            auctionHouseTreasury: accounts.auctionHouseTreasury,
            buyerTradeState: accounts.buyerTradeState,
            sellerTradeState: accounts.sellerTradeState,
            freeTradeState: accounts.freeTradeState,
            programAsSigner: accounts.programAsSigner
        )
    }
}

extension ExecutePartialSaleInstructionAccounts {
    init(accounts: SaleAccounts) {
        self.init(
            buyer: accounts.buyer,
            seller: accounts.seller,
            tokenAccount: accounts.tokenAccount,
            tokenMint: accounts.tokenMint,
            metadata: accounts.metadata,
            treasuryMint: accounts.treasuryMint,
            escrowPaymentAccount: accounts.escrowPaymentAccount,
            sellerPaymentReceiptAccount: accounts.sellerPaymentReceiptAccount,
            buyerReceiptTokenAccount: accounts.buyerReceiptTokenAccount,
            authority: accounts.authority,
            auctionHouse: accounts.auctionHouseAddress,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            auctionHouseTreasury: accounts.auctionHouseTreasury,
            buyerTradeState: accounts.buyerTradeState,
            sellerTradeState: accounts.sellerTradeState,
            freeTradeState: accounts.freeTradeState,
            programAsSigner: accounts.programAsSigner
        )
    }
}

extension AuctioneerExecuteSaleInstructionAccounts {
    init(auctioneerAuthority: PublicKey, auctioneerPda: PublicKey, accounts: SaleAccounts) {
        self.init(
            buyer: accounts.buyer,
            seller: accounts.seller,
            tokenAccount: accounts.tokenAccount,
            tokenMint: accounts.tokenMint,
            metadata: accounts.metadata,
            treasuryMint: accounts.treasuryMint,
            escrowPaymentAccount: accounts.escrowPaymentAccount,
            sellerPaymentReceiptAccount: accounts.sellerPaymentReceiptAccount,
            buyerReceiptTokenAccount: accounts.buyerReceiptTokenAccount,
            authority: accounts.authority,
            auctioneerAuthority: auctioneerAuthority,
            auctionHouse: accounts.auctionHouseAddress,
            auctionHouseFeeAccount: accounts.auctionHouseFeeAccount,
            auctionHouseTreasury: accounts.auctionHouseTreasury,
            buyerTradeState: accounts.buyerTradeState,
            sellerTradeState: accounts.sellerTradeState,
            freeTradeState: accounts.freeTradeState,
            ahAuctioneerPda: auctioneerPda,
            programAsSigner: accounts.programAsSigner
        )
    }
}
