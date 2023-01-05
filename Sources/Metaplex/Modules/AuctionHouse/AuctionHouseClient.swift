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

    public func create(
        sellerFeeBasisPoints: UInt16,
        requiresSignOff: Bool = false,
        canChangeSalePrice: Bool = false,
        auctioneerScopes: [AuthorityScope] = [],
        treasuryMint: PublicKey = Auctionhouse.treasuryMintDefault,
        payer: Account? = nil,
        authority: Account? = nil,
        feeWithdrawalDestination: Account? = nil,
        treasuryWithdrawalDestinationOwner: PublicKey? = nil,
        auctioneerAuthority: PublicKey? = nil,
        onComplete: @escaping (Result<Auctionhouse, OperationError>) -> Void
    ) {
        let operation = CreateAuctionHouseOperationHandler(metaplex: metaplex)
        operation.handle(operation: CreateAuctionHouseOperation.pure(.success(
            CreateAuctionHouseInput(
                sellerFeeBasisPoints: sellerFeeBasisPoints,
                requiresSignOff: requiresSignOff,
                canChangeSalePrice: canChangeSalePrice,
                auctioneerScopes: auctioneerScopes,
                treasuryMint: treasuryMint,
                payer: payer,
                authority: authority,
                feeWithdrawalDestination: feeWithdrawalDestination,
                treasuryWithdrawalDestinationOwner: treasuryWithdrawalDestinationOwner,
                auctioneerAuthority: auctioneerAuthority
            )
        ))).run { onComplete($0) }
    }

    public func findByAddress(_ address: PublicKey, onComplete: @escaping (Result<Auctionhouse, OperationError>) -> Void) {
        let operation = FindAuctionHouseByAddressOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindAuctionHouseByAddressOperation.pure(.success(address))).run { onComplete($0) }
    }

    public func findByCreatorAndMint(
        _ creator: PublicKey,
        and treasuryMint: PublicKey,
        onComplete: @escaping (Result<Auctionhouse, OperationError>) -> Void
    ) {
        let operation = FindAuctionHouseByCreatorAndMintOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindAuctionHouseByCreatorAndMintOperation.pure(.success(
            FindAuctionHouseByCreatorAndMintInput(creator: creator, treasuryMint: treasuryMint)
        ))).run { onComplete($0) }
    }

    // MARK: - Bid

    public func bid(
        auctionHouse: AuctionhouseArgs,
        buyer: Account? = nil,
        authority: Account? = nil,
        auctioneerAuthority: Account? = nil,
        mintAccount: PublicKey,
        seller: PublicKey? = nil,
        tokenAccountAddress: PublicKey? = nil,
        price: UInt64? = 0,
        tokens: UInt64? = 1,
        printReceipt: Bool = true,
        bookkeeper: Account? = nil,
        onComplete: @escaping (Result<Bid, OperationError>) -> Void
    ) {
        let operation = CreateBidOperationHandler(metaplex: metaplex)
        operation.handle(operation: CreateBidOperation.pure(.success(
            CreateBidInput(
                auctionHouse: auctionHouse,
                buyer: buyer,
                authority: authority,
                auctioneerAuthority: auctioneerAuthority,
                mintAccount: mintAccount,
                seller: seller,
                tokenAccountAddress: tokenAccountAddress,
                price: price,
                tokens: tokens,
                printReceipt: printReceipt,
                bookkeeper: bookkeeper
            )
        ))).run { onComplete($0) }
    }

    public func findBidByReceipt(
        _ address: PublicKey,
        auctionHouse: AuctionhouseArgs,
        onComplete: @escaping (Result<Bid, OperationError>) -> Void
    ) {
        let operation = FindBidByReceiptOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindBidByReceiptOperation.pure(.success(
            FindBidByReceiptInput(
                address: address,
                auctionHouse: auctionHouse
            )
        ))).run { onComplete($0) }
    }

    public func findBidByTradeState(
        _ address: PublicKey,
        auctionHouse: AuctionhouseArgs,
        onComplete: @escaping (Result<Bid, OperationError>) -> Void
    ) {
        let operation = FindBidByTradeStateOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindBidByTradeStateOperation.pure(.success(
            FindBidByTradeStateInput(address: address, auctionHouse: auctionHouse)
        ))).run { onComplete($0) }
    }

    public func findBidsBy(
        type: BidPublicKeyType,
        auctionHouse: AuctionhouseArgs,
        onComplete: @escaping (Result<[Bidreceipt], OperationError>) -> Void
    ) {
        let operation = FindBidsByPublicKeyFieldOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindBidsByPublicKeyFieldOperation.pure(.success(
            FindBidsByPublicKeyFieldInput(
                type: type,
                auctionHouse: auctionHouse
            )
        ))).run { onComplete($0) }
    }

    public func loadBid(_ bid: LazyBid, onComplete: @escaping (Result<Bid, OperationError>) -> Void) {
        let operation = LoadBidOperationHandler(metaplex: metaplex)
        operation.handle(operation: LoadBidOperation.pure(.success(bid))).run { onComplete($0) }
    }

    public func cancelBid(
        auctioneerAuthority: Account? = nil,
        auctionHouse: AuctionhouseArgs,
        bid: Bid,
        onComplete: @escaping (Result<SignatureStatus, OperationError>) -> Void
    ) {
        let operation = CancelBidOperationHandler(metaplex: metaplex)
        operation.handle(operation: CancelBidOperation.pure(.success(
            CancelBidInput(
                auctioneerAuthority: auctioneerAuthority,
                auctionHouse: auctionHouse,
                bid: bid
            )
        ))).run { onComplete($0) }
    }

    // MARK: - Listing

    public func list(
        auctionHouse: AuctionhouseArgs,
        seller: Account? = nil,
        authority: Account? = nil,
        auctioneerAuthority: Account? = nil,
        mintAccount: PublicKey,
        tokenAccount: PublicKey? = nil,
        price: UInt64,
        tokens: UInt64 = 1,
        printReceipt: Bool = true,
        bookkeeper: Account? = nil,
        onComplete: @escaping (Result<Listing, OperationError>) -> Void
    ) {
        let operation = CreateListingOperationHandler(metaplex: metaplex)
        operation.handle(operation: CreateListingOperation.pure(.success(
            CreateListingInput(
                auctionHouse: auctionHouse,
                seller: seller,
                authority: authority,
                auctioneerAuthority: auctioneerAuthority,
                mintAccount: mintAccount,
                tokenAccount: tokenAccount,
                price: price,
                tokens: tokens,
                printReceipt: printReceipt,
                bookkeeper: bookkeeper
            )
        ))).run { onComplete($0) }
    }

    public func findListingByReceipt(
        _ address: PublicKey,
        auctionHouse: AuctionhouseArgs,
        onComplete: @escaping (Result<Listing, OperationError>) -> Void
    ) {
        let operation = FindListingByReceiptOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindListingByReceiptOperation.pure(.success(
            FindListingByReceiptInput(
                address: address,
                auctionHouse: auctionHouse
            )
        ))).run { onComplete($0) }
    }

    public func loadListing(_ listing: LazyListing, onComplete: @escaping (Result<Listing, OperationError>) -> Void) {
        let operation = LoadListingOperationHandler(metaplex: metaplex)
        operation.handle(operation: LoadListingOperation.pure(.success(listing))).run { onComplete($0) }
    }

    public func cancelListing(
        auctioneerAuthority: Account? = nil,
        auctionHouse: Auctionhouse,
        listing: Listing,
        onComplete: @escaping (Result<SignatureStatus, OperationError>) -> Void
    ) {
        let operation = CancelListingOperationHandler(metaplex: metaplex)
        operation.handle(operation: CancelListingOperation.pure(.success(
            CancelListingInput(
                auctioneerAuthority: auctioneerAuthority,
                auctionHouse: auctionHouse,
                listing: listing
            )
        ))).run { onComplete($0) }
    }

    // MARK: - Sale

    public func executeSale(
        bid: Bid,
        listing: Listing,
        auctionHouse: AuctionhouseArgs,
        auctioneerAuthority: Account? = nil,
        bookkeeper: Account? = nil,
        printReceipt: Bool = true,
        onComplete: @escaping (Result<Purchase, OperationError>) -> Void
    ) {
        let operation = ExecuteSaleOperationHandler(metaplex: metaplex)
        operation.handle(operation: ExecuteSaleOperation.pure(.success(
            ExecuteSaleInput(
                bid: bid,
                listing: listing,
                auctionHouse: auctionHouse,
                auctioneerAuthority: auctioneerAuthority,
                bookkeeper: bookkeeper,
                printReceipt: printReceipt
            )
        ))).run { onComplete($0) }
    }

    public func findPurchaseByReceipt(
        _ address: PublicKey,
        auctionHouse: AuctionhouseArgs,
        onComplete: @escaping (Result<Purchase, OperationError>) -> Void
    ) {
        let operation = FindPurchaseByReceiptOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindPurchaseByReceiptOperation.pure(.success(
            FindPurchaseByReceiptInput(
                address: address,
                auctionHouse: auctionHouse
            )
        ))).run { onComplete($0) }
    }

    public func loadPurchase(_ purchase: LazyPurchase, onComplete: @escaping (Result<Purchase, OperationError>) -> Void) {
        let operation = LoadPurchaseOperationHandler(metaplex: metaplex)
        operation.handle(operation: LoadPurchaseOperation.pure(.success(purchase))).run { onComplete($0) }
    }
}
