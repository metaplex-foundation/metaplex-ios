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

    func create(
        input: CreateAuctionHouseInput,
        onComplete: @escaping (Result<Auctionhouse, OperationError>) -> Void
    ) {
        let operation = CreateAuctionHouseOperationHandler(metaplex: metaplex)
        operation.handle(operation: CreateAuctionHouseOperation.pure(.success(input))).run { onComplete($0) }
    }

    func findByAddress(_ address: PublicKey, onComplete: @escaping (Result<Auctionhouse, OperationError>) -> Void) {
        let operation = FindAuctionHouseByAddressOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindAuctionHouseByAddressOperation.pure(.success(address))).run { onComplete($0) }
    }

    func findByCreatorAndMint(_ creator: PublicKey, and treasuryMint: PublicKey, onComplete: @escaping (Result<Auctionhouse, OperationError>) -> Void) {
        let operation = FindAuctionHouseByCreatorAndMintOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindAuctionHouseByCreatorAndMintOperation.pure(.success(
            FindAuctionHouseByCreatorAndMintInput(creator: creator, treasuryMint: treasuryMint)
        ))).run { onComplete($0) }
    }

    // MARK: - Bid

    func bid(
        input: CreateBidInput
        onComplete: @escaping (Result<Bid, OperationError>) -> Void
    ) {
        let operation = CreateBidOperationHandler(metaplex: metaplex)
        operation.handle(operation: CreateBidOperation.pure(.success(input))).run { onComplete($0) }
    }

    func findBidByReceipt(
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

    func findBidByTradeState(
        _ address: PublicKey,
        auctionHouse: Auctionhouse,
        onComplete: @escaping (Result<Bid, OperationError>) -> Void
    ) {
        let operation = FindBidByTradeStateOperationHandler(metaplex: metaplex)
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
        let operation = FindBidsByPublicKeyFieldOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindBidsByPublicKeyFieldOperation.pure(.success(
            FindBidsByPublicKeyFieldInput(
                field: type,
                auctionHouse: auctionHouse,
                publicKey: publicKey
            )
        ))).run { onComplete($0) }
    }

    func loadBid(_ bid: LazyBid, onComplete: @escaping (Result<Bid, OperationError>) -> Void) {
        let operation = LoadBidOperationHandler(metaplex: metaplex)
        operation.handle(operation: LoadBidOperation.pure(.success(bid))).run { onComplete($0) }
    }

    func cancelBid(
        input: CancelBidInput,
        onComplete: @escaping (Result<SignatureStatus, OperationError>) -> Void
    ) {
        let operation = CancelBidOperationHandler(metaplex: metaplex)
        operation.handle(operation: CancelBidOperation.pure(.success(input))).run { onComplete($0) }
    }

    // MARK: - Listing

    func list(
        input: CancelBidInput,
        onComplete: @escaping (Result<Listing, OperationError>) -> Void
    ) {
        let operation = CreateListingOperationHandler(metaplex: metaplex)
        operation.handle(operation: CreateListingOperation.pure(.success(input))).run { onComplete($0) }
    }

    func findListingByReceipt(
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

    func loadListing(_ listing: LazyListing, onComplete: @escaping (Result<Listing, OperationError>) -> Void) {
        let operation = LoadListingOperationHandler(metaplex: metaplex)
        operation.handle(operation: LoadListingOperation.pure(.success(listing))).run { onComplete($0) }
    }

    func cancelListing(
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

    func executeSale(
        input: ExecuteSaleInput
        onComplete: @escaping (Result<Purchase, OperationError>) -> Void
    ) {
        let operation = ExecuteSaleOperationHandler(metaplex: metaplex)
        operation.handle(operation: ExecuteSaleOperation.pure(.success(input))).run { onComplete($0) }
    }

    func findPurchaseByReceipt(
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

    func loadPurchase(_ purchase: LazyPurchase, onComplete: @escaping (Result<Purchase, OperationError>) -> Void) {
        let operation = LoadPurchaseOperationHandler(metaplex: metaplex)
        operation.handle(operation: LoadPurchaseOperation.pure(.success(purchase))).run { onComplete($0) }
    }
}
