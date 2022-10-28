//
//  File.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/17/22.
//

import AuctionHouse
import Foundation
import Solana

struct CancelListingBuilderParameters {
    // MARK: - Initialization

    private let cancelListingInput: CancelListingInput
    let tokenAccount: PublicKey
    let auctionHouse: PublicKey

    init(
        cancelListingInput: CancelListingInput,
        tokenAccount: PublicKey,
        auctionHouse: PublicKey
    ) {
        self.cancelListingInput = cancelListingInput
        self.tokenAccount = tokenAccount
        self.auctionHouse = auctionHouse
    }

    // MARK: - Getters

    // MARK: - Accounts

    var wallet: PublicKey { cancelListingInput.listing.listingReceipt.seller }
    var tokenMint: PublicKey { cancelListingInput.listing.nft.mint }
    var authority: PublicKey { cancelListingInput.listing.listingReceipt.auctionHouse.authority }
    var auctionHouseFeeAccount: PublicKey { cancelListingInput.listing.listingReceipt.auctionHouse.auctionHouseFeeAccount }
    var tradeState: PublicKey { cancelListingInput.listing.listingReceipt.tradeState.publicKey }
    var auctioneerPda: PublicKey? {
        guard let auctioneerAuthoritySigner else { return nil }
        return try? Auctionhouse.auctioneerPda(
            auctionHouse: auctionHouse,
            auctioneerAuthority: auctioneerAuthoritySigner.publicKey
        ).get()
    }
    var receipt: PublicKey? { cancelListingInput.listing.listingReceipt.receipt?.publicKey }


    // MARK: - Args

    var price: UInt64 { cancelListingInput.listing.listingReceipt.price }
    var tokenSize: UInt64 { cancelListingInput.listing.listingReceipt.tokenSize }

    // MARK: - Signers

    var auctioneerAuthoritySigner: Account? { cancelListingInput.auctioneerAuthority }
}
