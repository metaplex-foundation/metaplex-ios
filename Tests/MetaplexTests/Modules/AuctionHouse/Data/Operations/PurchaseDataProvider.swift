//
//  PurchaseDataProvider.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

import AuctionHouse
import Foundation
import Solana

@testable import Metaplex

struct PurchaseDataProvider {
    static func executeSale(_ metaplex: Metaplex, bid: Bid, listing: Listing, auctionHouse: AuctionhouseArgs) -> Purchase? {
        var result: Result<Purchase, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = ExecuteSaleOperationHandler(metaplex: metaplex)
            operation.handle(operation: ExecuteSaleOperation.pure(.success(
                ExecuteSaleInput(bid: bid, listing: listing, auctionHouse: auctionHouse)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func findPurchaseByReceipt(_ metaplex: Metaplex, address: PublicKey, auctionHouse: AuctionhouseArgs) -> Purchase? {
        var result: Result<Purchase, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = FindPurchaseByReceiptOperationHandler(metaplex: metaplex)
            operation.handle(operation: FindPurchaseByReceiptOperation.pure(.success(
                FindPurchaseByReceiptInput(address: address, auctionHouse: auctionHouse)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func loadPurchase(_ metaplex: Metaplex, purchase: LazyPurchase) -> Purchase? {
        var result: Result<Purchase, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = LoadPurchaseOperationHandler(metaplex: metaplex)
            operation.handle(operation: LoadPurchaseOperation.pure(.success(purchase))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }
}
