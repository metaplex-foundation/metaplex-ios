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
    let auctionHouse: AuctionhouseArgs
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
            guard let tokenAccount = try? PublicKey.associatedTokenAddress(
                walletAddress: input.bid.bidReceipt.buyer,
                tokenMintAddress: input.bid.nft.mint
            ).get(), let auctionHouse = try? Auctionhouse.pda(
                creator: input.auctionHouse.creator,
                treasuryMint: input.auctionHouse.treasuryMint
            ).get().publicKey else {
                return .failure(.couldNotFindPDA)
            }

            let parameters = CancelBidBuilderParameters(
                cancelBidInput: input,
                tokenAccount: tokenAccount,
                auctionHouse: auctionHouse
            )
            
            let cancelBidBuilder = TransactionBuilder.cancelBidBuilder(parameters: parameters)
            return OperationResult<SignatureStatus, OperationError>.init { callback in
                cancelBidBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
                    switch result {
                    case .success(let status):
                        callback(.success(status))
                    case .failure(let error):
                        callback(.failure(.confirmTransactionError(error)))
                    }
                }
            }
        }
    }
}
