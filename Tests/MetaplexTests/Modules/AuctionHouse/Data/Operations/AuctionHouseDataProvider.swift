//
//  AuctionHouseDataProvider.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/27/22.
//

import AuctionHouse
import Foundation

@testable import Metaplex

struct AuctionHouseDataProvider {
    static func createAuctionHouse(_ metaplex: Metaplex) -> Auctionhouse? {
        guard let auctionHouse = create(metaplex) else { return nil }

        TestDataProvider.airDropFunds(metaplex, account: auctionHouse.auctionHouseFeeAccount)

        return auctionHouse
    }

    private static func create(_ metaplex: Metaplex) -> Auctionhouse? {
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
}
