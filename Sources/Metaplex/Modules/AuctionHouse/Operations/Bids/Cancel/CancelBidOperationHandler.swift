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
            switch self.createParametersFromInput(input) {
            case .success(let parameters):
                return self.createOperationResult(parameters)
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    // MARK: - Private Helpers

    private func createParametersFromInput(
        _ input: CancelBidInput
    ) -> Result<CancelBidBuilderParameters, OperationError> {
        guard let tokenAccount = try? PublicKey.associatedTokenAddress(
            walletAddress: input.bid.bidReceipt.buyer,
            tokenMintAddress: input.bid.nft.mint
        ).get()
        else { return .failure(.couldNotFindTokenAccount) }

        guard let auctionHouse = try? Auctionhouse.pda(
            creator: input.auctionHouse.creator,
            treasuryMint: input.auctionHouse.treasuryMint
        ).get().publicKey
        else { return .failure(.couldNotFindAuctionHouse) }

        let parameters = CancelBidBuilderParameters(
            cancelBidInput: input,
            tokenAccount: tokenAccount,
            auctionHouse: auctionHouse
        )
        return .success(parameters)
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
