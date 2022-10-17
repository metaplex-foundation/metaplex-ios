//
//  AuctionHouseClient.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/14/22.
//

import AuctionHouse
import Foundation
import Solana

public class AuctionHouseClient {
    let metaplex: Metaplex

    public init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    // MARK: - Auction House

    func findByAddress(_ address: PublicKey, onComplete: @escaping (Result<Auctionhouse, OperationError>) -> Void) {
        let operation = FindAuctionHouseByAddressOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindAuctionHouseByAddressOperation.pure(.success(address))).run { onComplete($0) }
    }

    func findByCreatorAndMint(_ creator: PublicKey, and treasuryMint: PublicKey, onComplete: @escaping (Result<Auctionhouse, OperationError>) -> Void) {
        let operation = FindAuctionHouseByCreatorAndMintOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindAuctionHouseByCreatorAndMintOperation.pure(.success(
            FindAuctionHouseByCreatorAndMintInput(creator: creator, treasuryMint: treasuryMint)
        ))).run { onComplete($0) }
    }

    // MARK: - Bid

    func bid(
        _ auctionHouse: Auctionhouse,
        buyer: Account? = nil,
        authority: Account? = nil,
        auctioneerAuthority: Account? = nil,
        mintAccount: PublicKey,
        seller: PublicKey?,
        tokenAccount: PublicKey?,
        price: UInt64? = nil,
        tokens: UInt64? = nil,
        printReceipt: Bool = true,
        bookkeeper: Account? = nil,
        onComplete: @escaping (Result<Bid, OperationError>) -> Void
    ) {
        let operation = CreateBidOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: CreateBidOperation.pure(.success(
            CreateBidInput(
                auctionHouse: auctionHouse,
                buyer: buyer,
                authority: authority,
                auctioneerAuthority: auctioneerAuthority,
                mintAccount: mintAccount,
                seller: seller,
                tokenAccount: tokenAccount,
                price: price,
                tokens: tokens,
                printReceipt: printReceipt,
                bookkeeper: bookkeeper
            )
        ))).run { onComplete($0) }
    }

    func findBidByReceipt(
        _ address: PublicKey,
        auctionHouse: Auctionhouse,
        onComplete: @escaping (Result<Bid, OperationError>) -> Void
    ) {
        let operation = FindBidByReceiptOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindBidByReceiptOperation.pure(.success(
            FindBidByReceiptInput(
                address: address,
                auctionHouse: auctionHouse
            )
        ))).run { onComplete($0) }
    }

    func findBidByTradeState(
        _ address: PublicKey,
        auctionHouse: Auctionhouse,
        onComplete: @escaping (Result<Bid, OperationError>) -> Void
    ) {
        let operation = FindBidByTradeStateOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindBidByTradeStateOperation.pure(.success(
            FindBidByTradeStateInput(address: address, auctionHouse: auctionHouse)
        ))).run { onComplete($0) }
    }

    func findBidsBy(
        type: FindBidsByPublicKeyFieldInput.Field,
        auctionHouse: Auctionhouse,
        publicKey: PublicKey,
        onComplete: @escaping (Result<[Bidreceipt], OperationError>) -> Void
    ) {
        let operation = FindBidsByPublicKeyFieldOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindBidsByPublicKeyFieldOperation.pure(.success(
            FindBidsByPublicKeyFieldInput(
                field: type,
                auctionHouse: auctionHouse,
                publicKey: publicKey
            )
        ))).run { onComplete($0) }
    }

    func loadBid(_ bid: LazyBid, onComplete: @escaping (Result<Bid, OperationError>) -> Void) {
        let operation = LoadBidOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: LoadBidOperation.pure(.success(bid))).run { onComplete($0) }
    }

    func cancelBid(
        auctioneerAuthority: Account? = nil,
        auctionHouse: Auctionhouse,
        bid: Bid,
        onComplete: @escaping (Result<SignatureStatus, OperationError>) -> Void
    ) {
        let operation = CancelBidOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: CancelBidOperation.pure(.success(
            CancelBidInput(
                auctioneerAuthority: auctioneerAuthority,
                auctionHouse: auctionHouse,
                bid: bid
            )
        ))).run { onComplete($0) }
    }

    // MARK: - Listing

    func list(
        _ auctionHouse: Auctionhouse,
        auctioneerAuthority: Account?,
        mintAccount: PublicKey,
        onComplete: @escaping (Result<Listing, OperationError>) -> Void
    ) {
        let operation = CreateListingOperationHandler(metaplex: metaplex)
        operation.handle(operation: CreateListingOperation.pure(.success(
            CreateListingInput(
                auctionHouse: auctionHouse,
                auctioneerAuthority: auctioneerAuthority,
                mintAccount: mintAccount
            )
        ))).run { onComplete($0) }
    }

    func cancelListing(
        auctioneerAuthority: Account? = nil,
        auctionHouse: Auctionhouse,
        listing: Listing,
        onComplete: @escaping (Result<SignatureStatus, OperationError>) -> Void) {
        let operation = CancelListingOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: CancelListingOperation.pure(.success(
            CancelListingInput(
                auctioneerAuthority: auctioneerAuthority,
                auctionHouse: auctionHouse,
                listing: listing
            )
        ))).run { onComplete($0) }
    }
}
