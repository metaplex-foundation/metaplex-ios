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

    let cancelListingInput: CancelListingInput
    let auctionHouseAddress: PublicKey
    let tokenAccount: PublicKey

    // MARK: - Getters

    var wallet: PublicKey {
        cancelListingInput.listing.listingReceipt.seller
    }

    var tokenMint: PublicKey {
        cancelListingInput.listing.nft.mint
    }

    var authority: PublicKey {
        cancelListingInput.listing.listingReceipt.auctionHouse.authority
    }

    var auctionHouseFeeAccount: PublicKey {
        cancelListingInput.listing.listingReceipt.auctionHouse.auctionHouseFeeAccount
    }

    var tradeState: PublicKey {
        cancelListingInput.listing.listingReceipt.tradeState.publicKey
    }

    var price: UInt64 {
        cancelListingInput.listing.listingReceipt.price
    }

    var tokenSize: UInt64 {
        cancelListingInput.listing.listingReceipt.tokenSize
    }

    var auctioneerAuthority: Account? {
        cancelListingInput.auctioneerAuthority
    }

    var auctioneerPda: PublicKey? {
        guard let auctioneerAuthority, let pda = try? Auctionhouse.auctioneerPda(
            auctionHouse: auctionHouseAddress,
            auctioneerAuthority: auctioneerAuthority.publicKey
        ).get() else {
            return nil
        }
        return pda
    }

    var purchaseReceipt: PublicKey? {
        cancelListingInput.listing.listingReceipt.purchaseReceipt
    }
}
