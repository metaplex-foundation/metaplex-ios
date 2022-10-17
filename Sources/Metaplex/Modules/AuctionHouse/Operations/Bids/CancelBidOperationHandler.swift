//
//  CancelBidOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/4/22.
//

import AuctionHouse
import Foundation
import Solana

public struct CancelBidInput {
    let auctioneerAuthority: Account?
    let auctionHouse: Auctionhouse
    let bid: Bid
}

typealias CancelBidOperation = OperationResult<CancelBidInput, OperationError>

class CancelBidOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = CancelBidInput
    typealias O = SignatureStatus

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: CancelBidOperation) -> OperationResult<SignatureStatus, OperationError> {
        operation.flatMap { input in
            let wallet = input.bid.bidReceipt.buyer
            let mint = input.bid.nft.mint

            guard case let .success(tokenAccount) = PublicKey.associatedTokenAddress(
                walletAddress: wallet,
                tokenMintAddress: mint
            ), let auctionHouseAddress = try? Auctionhouse.pda(
                creator: input.auctionHouse.creator,
                treasuryMint: input.auctionHouse.treasuryMint
            ).get() else {
                return .failure(.couldNotFindPDA)
            }

            let parameters = CancelBidBuilderParameters(
                wallet: wallet,
                tokenAccount: tokenAccount,
                mint: mint,
                auctionHouseAddress: auctionHouseAddress,
                auctionHouse: input.auctionHouse,
                bid: input.bid,
                auctioneerAuthority: input.auctioneerAuthority
            )
            
            let cancelBidBuilder = TransactionBuilder.cancelBidBuilder(parameters: parameters)
            return OperationResult<SignatureStatus, OperationError>.init { callback in
                cancelBidBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
                    switch result {
                    case .success(let status):
                        guard let status else {
                            callback(.failure(.nilSignatureStatus))
                            return
                        }
                        callback(.success(status))
                    case .failure(let error):
                        callback(.failure(.confirmTransactionError(error)))
                    }
                }
            }
        }
    }
}
