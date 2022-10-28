//
//  ListingDataProvider.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

import AuctionHouse
import Foundation
import Solana

@testable import Metaplex

struct ListingDataProvider {
    static func createListing(_ metaplex: Metaplex, auctionHouse: AuctionhouseArgs, mintAccount: PublicKey) -> Listing? {
        var result: Result<Listing, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = CreateListingOperationHandler(metaplex: metaplex)
            operation.handle(operation: CreateListingOperation.pure(.success(
                CreateListingInput(auctionHouse: auctionHouse, mintAccount: mintAccount, price: 650)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func findListingByReceipt(_ metaplex: Metaplex, address: PublicKey, auctionHouse: AuctionhouseArgs) -> Listing? {
        var result: Result<Listing, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = FindListingByReceiptOperationHandler(metaplex: metaplex)
            operation.handle(operation: FindListingByReceiptOperation.pure(.success(
                FindListingByReceiptInput(address: address, auctionHouse: auctionHouse)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func loadListing(_ metaplex: Metaplex, listing: LazyListing) -> Listing? {
        var result: Result<Listing, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = LoadListingOperationHandler(metaplex: metaplex)
            operation.handle(operation: LoadListingOperation.pure(.success(listing))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func cancelListing(_ metaplex: Metaplex, auctionHouse: AuctionhouseArgs, listing: Listing) -> SignatureStatus? {
        var result: Result<SignatureStatus, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = CancelListingOperationHandler(metaplex: metaplex)
            operation.handle(operation: CancelListingOperation.pure(.success(
                CancelListingInput(auctionHouse: auctionHouse, listing: listing)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }
}
