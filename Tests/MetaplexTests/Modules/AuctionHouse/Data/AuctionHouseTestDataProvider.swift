//
//  AuctionHouseTestDataProvider.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/20/22.
//

import AuctionHouse
import Foundation
import Solana

@testable import Metaplex

struct AuctionHouseTestDataProvider {
    static let creator = PublicKey(string: "95emj1a33Ei7B6ciu7gbPm7zRMRpFGs86g5nK5NiSdEK")!
    static let treasuryMint = PublicKey(string: "So11111111111111111111111111111111111111112")!

    static let address = PublicKey(string: "5xN42RZCk7wA4GjQU2VVDhda8LBL8fAnrKZK921sybLF")!

    static let expectedPublicKey = "5xN42RZCk7wA4GjQU2VVDhda8LBL8fAnrKZK921sybLF"
    static let expectedAuctionHouse = AuctionHouseMock()

    // MARK: - Auction House

    static func createAuctionHouse(_ metaplex: Metaplex) -> Auctionhouse? {
        var result: Result<Auctionhouse, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = CreateAuctionHouseOperationHandler(metaplex: metaplex)
            operation.handle(
                operation: CreateAuctionHouseOperation.pure(.success(
                    CreateAuctionHouseInput(sellerFeeBasisPoints: 200, auctioneerAuthority: nil)
                ))
            ).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    // MARK: - Bid

    static func createBid(_ metaplex: Metaplex, auctionHouse: AuctionhouseArgs, nft: NFT) -> Bid? {
        var result: Result<Bid, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = CreateBidOperationHandler(metaplex: metaplex)
            operation.handle(operation: CreateBidOperation.pure(.success(
                CreateBidInput(auctionHouse: auctionHouse, mintAccount: nft.mint, price: 650)
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
