//
//  CancelBidOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/4/22.
//

import AuctionHouse
import Foundation
import Solana

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
            guard let parameters = self.createParametersFromInput(input) else {
                return .failure(.couldNotFindPDA)
            }
            return self.createOperationResult(parameters)
        }
    }

    // MARK: - Private Helpers

    private func createParametersFromInput(_ input: CancelBidInput) -> CancelBidBuilderParameters? {
        guard let tokenAccount = try? PublicKey.associatedTokenAddress(
            walletAddress: input.bid.bidReceipt.buyer,
            tokenMintAddress: input.bid.nft.mint
        ).get(), let auctionHouse = try? Auctionhouse.pda(
            creator: input.auctionHouse.creator,
            treasuryMint: input.auctionHouse.treasuryMint
        ).get().publicKey else {
            return nil // .failure(.couldNotFindPDA)
        }

        return CancelBidBuilderParameters(
            cancelBidInput: input,
            tokenAccount: tokenAccount,
            auctionHouse: auctionHouse
        )
    }

    private func createOperationResult(
        _ parameters: CancelBidBuilderParameters
    ) -> OperationResult<SignatureStatus, OperationError> {
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
