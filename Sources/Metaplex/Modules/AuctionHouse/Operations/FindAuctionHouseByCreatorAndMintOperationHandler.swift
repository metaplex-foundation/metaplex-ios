//
//  FindAuctionHouseByCreatorAndMintOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/19/22.
//

import AuctionHouse
import Foundation
import Solana

public struct FindAuctionHouseByCreatorAndMintInput {
    let creator: PublicKey
    let treasuryMint: PublicKey
}

typealias FindAuctionHouseByCreatorAndMintOperation = OperationResult<FindAuctionHouseByCreatorAndMintInput, OperationError>

class FindAuctionHouseByCreatorAndMintOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = FindAuctionHouseByCreatorAndMintInput
    typealias O = Auctionhouse

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindAuctionHouseByCreatorAndMintOperation) -> OperationResult<Auctionhouse, OperationError> {
        operation.flatMap { input in
            OperationResult.pure(Auctionhouse.pda(creator: input.creator, treasuryMint: input.treasuryMint)).flatMap { address in
                OperationResult<Auctionhouse, Error>.init { callback in
                    self.metaplex.auctionHouse.findByAddress(address) { result in
                        callback(result.mapError { $0 } )
                    }
                }
            }.mapError { OperationError.findAuctionHouseByCreatorAndMintError($0) }
        }
    }
}
