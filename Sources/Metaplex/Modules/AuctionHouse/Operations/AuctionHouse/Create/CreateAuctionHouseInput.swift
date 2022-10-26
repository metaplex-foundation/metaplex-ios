//
//  CreateAuctionHouseInput.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/26/22.
//

import AuctionHouse
import Foundation
import Solana

public struct CreateAuctionHouseInput {
    let sellerFeeBasisPoints: UInt16
    let requiresSignOff: Bool
    let canChangeSalePrice: Bool
    let auctioneerScopes: [AuthorityScope]
    let treasuryMint: PublicKey
    let payer: Account?
    let authority: Account?
    let feeWithdrawalDestination: Account?
    let treasuryWithdrawalDestinationOwner: PublicKey?
    let auctioneerAuthority: PublicKey?

    init(
        sellerFeeBasisPoints: UInt16,
        requiresSignOff: Bool = false,
        canChangeSalePrice: Bool = false,
        auctioneerScopes: [AuthorityScope] = [],
        treasuryMint: PublicKey = Auctionhouse.treasuryMintDefault,
        payer: Account? = nil,
        authority: Account? = nil,
        feeWithdrawalDestination: Account? = nil,
        treasuryWithdrawalDestinationOwner: PublicKey? = nil,
        auctioneerAuthority: PublicKey? = nil
    ) {
        self.sellerFeeBasisPoints = sellerFeeBasisPoints
        self.requiresSignOff = requiresSignOff
        self.canChangeSalePrice = canChangeSalePrice
        self.auctioneerScopes = auctioneerScopes
        self.treasuryMint = treasuryMint
        self.payer = payer
        self.authority = authority
        self.feeWithdrawalDestination = feeWithdrawalDestination
        self.treasuryWithdrawalDestinationOwner = treasuryWithdrawalDestinationOwner
        self.auctioneerAuthority = auctioneerAuthority
    }
}
