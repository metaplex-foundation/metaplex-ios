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

    func findBidByReceipt(_ address: PublicKey, onComplete: @escaping (Result<Bid, OperationError>) -> Void) {
        let operation = FindBidByReceiptOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindBidByReceiptOperation.pure(.success(address))).run { onComplete($0) }
    }

    func findBidByTradeState(_ address: PublicKey, onComplete: @escaping (Result<Bid, OperationError>) -> Void) {
        let operation = FindBidByTradeStateOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: FindBidByTradeStateOperation.pure(.success(address))).run { onComplete($0) }
    }

    func findBidsBy() {

    }

    func loadBid(_ bid: Bidreceipt, onComplete: @escaping (Result<Bid, OperationError>) -> Void) {
        let operation = LoadBidOperationHandler(metaplex: self.metaplex)
        operation.handle(operation: LoadBidOperation.pure(.success(bid))).run { onComplete($0) }
    }
}
