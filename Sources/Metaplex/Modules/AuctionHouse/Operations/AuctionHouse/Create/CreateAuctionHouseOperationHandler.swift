//
//  CreateAuctionHouseOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/21/22.
//

import AuctionHouse
import Foundation
import Solana

typealias CreateAuctionHouseOperation = OperationResult<CreateAuctionHouseInput, OperationError>

class CreateAuctionHouseOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = CreateAuctionHouseInput
    typealias O = Auctionhouse

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: CreateAuctionHouseOperation) -> OperationResult<Auctionhouse, OperationError> {
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
        _ input: CreateAuctionHouseInput
    ) -> Result<CreateAuctionHouseBuilderParameters, OperationError> {
        let defaultIdentity = metaplex.identity()

        let authority = input.authority ?? defaultIdentity
        let treasuryWithdrawalDestination: PublicKey? = {
            let destinationOwner = input.treasuryWithdrawalDestinationOwner ?? defaultIdentity.publicKey
            let publicKey = input.treasuryMint == Auctionhouse.treasuryMintDefault
            ? destinationOwner
            : PublicKey.findAssociatedTokenAccountPda(
                mint: input.treasuryMint,
                owner: destinationOwner
            )
            return publicKey
        }()

        guard let auctionHousePda = try? Auctionhouse.pda(
            creator: authority.publicKey,
            treasuryMint: input.treasuryMint
        ).get()
        else { return .failure(.couldNotFindAuctionHouse) }

        guard let auctionHouseFeePda = try? Auctionhouse.feePda(
            auctionHouse: auctionHousePda.publicKey
        ).get()
        else { return .failure(.couldNotFindAuctionHouseFeePda) }

        guard let auctionHouseTreasuryPda = try? Auctionhouse.treasuryPda(
            auctionHouse: auctionHousePda.publicKey
        ).get()
        else { return .failure(.couldNotFindAuctionHouseTreasuryPda) }

        guard let treasuryWithdrawalDestination else {
            return .failure(.couldNotFindTreasuryWithdrawalDestination)
        }

        let parameters = CreateAuctionHouseBuilderParameters(
            createAuctionHouseInput: input,
            auctionHousePda: auctionHousePda,
            auctionHouseFeePda: auctionHouseFeePda,
            auctionHouseTreasuryPda: auctionHouseTreasuryPda,
            treasuryWithdrawalDestination: treasuryWithdrawalDestination,
            defaultIdentity: defaultIdentity
        )
        return .success(parameters)
    }

    private func createOperationResult(
        _ parameters: CreateAuctionHouseBuilderParameters
    ) -> OperationResult<Auctionhouse, OperationError> {
        let createAuctionHouseBuilder = TransactionBuilder.createAuctionHouseBuilder(parameters: parameters)
        let operation = OperationResult<SignatureStatus, OperationError>.init { callback in
            createAuctionHouseBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
                switch result {
                case .success(let status):
                    callback(.success(status))
                case .failure(let error):
                    callback(.failure(.confirmTransactionError(error)))
                }
            }
        }.flatMap { status in
            OperationResult<Auctionhouse, OperationError>.init { callback in
                self.metaplex.auctionHouse.findByAddress(parameters.auctionHouse) { callback($0) }
            }
        }
        return operation
    }
}
