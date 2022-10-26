//
//  CreateAuctionHouseOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/21/22.
//

import AuctionHouse
import Foundation
import Solana

public struct CreateAuctionHouseInput {
    let sellerFeeBasisPoints: UInt16
    let requiresSignOff: Bool
    let canChangeSalePrice: Bool
    let auctioneerScopes: [AuthorityScope]
    let treasuryMint: PublicKey
    let payer: Account?
    let authority: Account?
    let feeWithdrawalDestination: Account?
    let treasuryWithdrawalDestinationOwner: PublicKey?
    let auctioneerAuthority: PublicKey?

    init(
        sellerFeeBasisPoints: UInt16,
        requiresSignOff: Bool = false,
        canChangeSalePrice: Bool = false,
        auctioneerScopes: [AuthorityScope] = [],
        treasuryMint: PublicKey = Auctionhouse.treasuryMintDefault,
        payer: Account? = nil,
        authority: Account? = nil,
        feeWithdrawalDestination: Account? = nil,
        treasuryWithdrawalDestinationOwner: PublicKey? = nil,
        auctioneerAuthority: PublicKey?
    ) {
        self.sellerFeeBasisPoints = sellerFeeBasisPoints
        self.requiresSignOff = requiresSignOff
        self.canChangeSalePrice = canChangeSalePrice
        self.auctioneerScopes = auctioneerScopes
        self.treasuryMint = treasuryMint
        self.payer = payer
        self.authority = authority
        self.feeWithdrawalDestination = feeWithdrawalDestination
        self.treasuryWithdrawalDestinationOwner = treasuryWithdrawalDestinationOwner
        self.auctioneerAuthority = auctioneerAuthority
    }
}

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
            guard let parameters = self.createParametersFromInput(input) else { return .failure(.couldNotFindPDA) } // TODO: Fix error here, maybe throw from `createParametersFromInput(_:)`
            return self.createOperationResult(parameters)
        }
    }

    private func createParametersFromInput(_ input: CreateAuctionHouseInput) -> CreateAuctionHouseBuilderParameters? {
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
        ).get(), let auctionHouseFeePda = try? Auctionhouse.feePda(
            auctionHouse: auctionHousePda.publicKey
        ).get(), let auctionHouseTreasuryPda = try? Auctionhouse.treasuryPda(
            auctionHouse: auctionHousePda.publicKey
        ).get(), let treasuryWithdrawalDestination else {
            return nil
        }

        return CreateAuctionHouseBuilderParameters(
            createAuctionHouseInput: input,
            auctionHousePda: auctionHousePda,
            auctionHouseFeePda: auctionHouseFeePda,
            auctionHouseTreasuryPda: auctionHouseTreasuryPda,
            treasuryWithdrawalDestination: treasuryWithdrawalDestination,
            defaultIdentity: defaultIdentity
        )
    }

    private func createOperationResult(_ parameters: CreateAuctionHouseBuilderParameters) -> OperationResult<Auctionhouse, OperationError> {
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
