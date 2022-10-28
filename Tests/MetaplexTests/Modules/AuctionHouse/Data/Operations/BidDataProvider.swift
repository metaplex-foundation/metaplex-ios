//
//  BidDataProvider.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

import AuctionHouse
import Foundation
import Solana

@testable import Metaplex

struct BidDataProvider {
    static func createBid(_ metaplex: Metaplex, auctionHouse: AuctionhouseArgs, nft: NFT, buyer: Account? = nil) -> Bid? {
        var result: Result<Bid, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = CreateBidOperationHandler(metaplex: metaplex)
            operation.handle(operation: CreateBidOperation.pure(.success(
                CreateBidInput(auctionHouse: auctionHouse, buyer: buyer, mintAccount: nft.mint, price: 650)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func findBidByReceipt(_ metaplex: Metaplex, address: PublicKey, auctionHouse: AuctionhouseArgs) -> Bid? {
        var result: Result<Bid, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = FindBidByReceiptOperationHandler(metaplex: metaplex)
            operation.handle(operation: FindBidByReceiptOperation.pure(.success(
                FindBidByReceiptInput(address: address, auctionHouse: auctionHouse)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func findBidByTradeState(_ metaplex: Metaplex, address: PublicKey, auctionHouse: AuctionhouseArgs) -> Bid? {
        var result: Result<Bid, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = FindBidByTradeStateOperationHandler(metaplex: metaplex)
            operation.handle(operation: FindBidByTradeStateOperation.pure(.success(
                FindBidByTradeStateInput(address: address, auctionHouse: auctionHouse)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func findBidsBy(_ metaplex: Metaplex, type: BidPublicKeyType, auctionHouse: AuctionhouseArgs) -> [Bidreceipt] {
        var result: Result<[Bidreceipt], OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = FindBidsByPublicKeyFieldOperationHandler(metaplex: metaplex)
            operation.handle(operation: FindBidsByPublicKeyFieldOperation.pure(.success(
                FindBidsByPublicKeyFieldInput(type: type, auctionHouse: auctionHouse)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return (try? result?.get()) ?? []
    }

    static func loadBid(_ metaplex: Metaplex, bid: LazyBid) -> Bid? {
        var result: Result<Bid, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = LoadBidOperationHandler(metaplex: metaplex)
            operation.handle(operation: LoadBidOperation.pure(.success(bid))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    static func cancelBid(_ metaplex: Metaplex, auctionHouse: AuctionhouseArgs, bid: Bid) -> SignatureStatus? {
        var result: Result<SignatureStatus, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = CancelBidOperationHandler(metaplex: metaplex)
            operation.handle(operation: CancelBidOperation.pure(.success(
                CancelBidInput(auctioneerAuthority: nil, auctionHouse: auctionHouse, bid: bid)
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }
}
