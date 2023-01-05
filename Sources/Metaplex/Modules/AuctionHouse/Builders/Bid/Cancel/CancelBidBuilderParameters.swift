//
//  CancelBidBuilderParameters.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/25/22.
//

import AuctionHouse
import Foundation
import Solana

struct CancelBidBuilderParameters {
    // MARK: - Initialization

    private let cancelBidInput: CancelBidInput

    let tokenAccount: PublicKey
    let auctionHouse: PublicKey

    init(
        cancelBidInput: CancelBidInput,
        tokenAccount: PublicKey,
        auctionHouse: PublicKey
    ) {
        self.cancelBidInput = cancelBidInput
        self.tokenAccount = tokenAccount
        self.auctionHouse = auctionHouse
    }

    // MARK: - Getters

    // MARK: - Accounts

    var wallet: PublicKey { cancelBidInput.bid.bidReceipt.buyer  }
    var tokenMint: PublicKey { cancelBidInput.bid.nft.mint }
    var authority: PublicKey { cancelBidInput.auctionHouse.authority }
    var auctionHouseFeeAccount: PublicKey { cancelBidInput.auctionHouse.auctionHouseFeeAccount }
    var tradeState: PublicKey { cancelBidInput.bid.bidReceipt.tradeState.publicKey }
    var auctioneerPda: PublicKey? {
        guard let auctioneerAuthoritySigner else { return nil }
        return try? Auctionhouse.auctioneerPda(
            auctionHouse: auctionHouse,
            auctioneerAuthority: auctioneerAuthoritySigner.publicKey
        ).get()
    }
    var receipt: PublicKey? { cancelBidInput.bid.bidReceipt.receipt?.publicKey }

    // MARK: - Args

    var buyerPrice: UInt64 { cancelBidInput.bid.bidReceipt.price }
    var tokenSize: UInt64 { cancelBidInput.bid.bidReceipt.tokenSize }

    // MARK: - Signers

    var auctioneerAuthoritySigner: Account? { cancelBidInput.auctioneerAuthority }
}
