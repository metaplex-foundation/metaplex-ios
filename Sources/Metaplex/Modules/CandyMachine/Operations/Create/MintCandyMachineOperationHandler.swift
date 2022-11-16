//
//  MintCandyMachineOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/3/22.
//

import CandyMachine
import Foundation
import Solana

typealias MintCandyMachineOperation = OperationResult<MintCandyMachineInput, OperationError>

class MintCandyMachineOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = MintCandyMachineInput
    typealias O = NFT

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: MintCandyMachineOperation) -> OperationResult<NFT, OperationError> {
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
        _ input: MintCandyMachineInput
    ) -> Result<MintCandyMachineBuilderParameters, OperationError> {
        let defaultIdentity = metaplex.identity()

        guard let candyMachineCreatorPda = try? Candymachine.pda(address: input.candyMachine.address).get()
        else { return .failure(.couldNotFindCandyMachineCreatorPda) }

        guard let metadata = try? MetadataAccount.pda(mintKey: input.newMint.publicKey).get()
        else { return .failure(.couldNotFindMetadata) }

        guard let masterEdition = try? MasterEditionAccount.pda(mintKey: input.mint).get()
        else { return .failure(.couldNotFindMasterEdition) }

        let owner = input.newOwner ?? defaultIdentity.publicKey
        guard let associatedAccount = PublicKey.findAssociatedTokenAccountPda(mint: input.mint, owner: owner)
        else { return .failure(.couldNotFindTokenAccount) }

        let parameters = MintCandyMachineBuilderParameters(
            mintCandyMachineInput: input,
            candyMachineCreatorPda: candyMachineCreatorPda,
            metadata: metadata,
            masterEdition: masterEdition,
            associatedAccount: associatedAccount,
            defaultIdentity: defaultIdentity
        )
        return .success(parameters)
    }

    private func createOperationResult(
        _ parameters: MintCandyMachineBuilderParameters
    ) -> OperationResult<NFT, OperationError> {
        let MintCandyMachineBuilder = TransactionBuilder.mintCandyMachineBuilder(parameters: parameters)
        let operation = OperationResult<SignatureStatus, OperationError>.init { callback in
            MintCandyMachineBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
                switch result {
                case .success(let status):
                    callback(.success(status))
                case .failure(let error):
                    callback(.failure(.confirmTransactionError(error)))
                }
            }
        }.flatMap { _ in
            OperationResult<NFT, OperationError>.init { callback in
                self.metaplex.nft.findByMint(mintKey: parameters.mint) {
                    callback($0)
                }
            }
        }
        return operation
    }
}
