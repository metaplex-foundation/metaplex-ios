//
//  CancelListingOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/16/22.
//

import AuctionHouse
import Foundation
import Solana

public struct CancelListingInput {
    let auctioneerAuthority: Account?
    let auctionHouse: Auctionhouse
    let listing: Listing
}

typealias CancelListingOperation = OperationResult<CancelListingInput, OperationError>

class CancelListingOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = CancelListingInput
    typealias O = SignatureStatus

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: CancelListingOperation) -> OperationResult<SignatureStatus, OperationError> {
        operation.flatMap { input in
            guard let auctionHouse = try? Auctionhouse.pda(
                creator: input.auctionHouse.creator,
                treasuryMint: input.auctionHouse.treasuryMint
            ).get().publicKey, let tokenAccount = PublicKey.findAssociatedTokenAccountPda(
                mint: input.listing.nft.mint,
                owner: input.listing.listingReceipt.seller
            ) else {
                return .failure(.couldNotFindPDA)
            }

            let parameters = CancelListingBuilderParameters(
                cancelListingInput: input,
                tokenAccount: tokenAccount,
                auctionHouse: auctionHouse
            )

            let cancelListingBuilder = TransactionBuilder.cancelListingBuilder(parameters: parameters)
            return OperationResult<SignatureStatus, OperationError>.init { callback in
                cancelListingBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
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
