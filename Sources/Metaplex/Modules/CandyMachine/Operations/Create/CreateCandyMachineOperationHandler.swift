//
//  CreateCandyMachineOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/3/22.
//

import CandyMachine
import Foundation
import Solana

typealias CreateCandyMachineOperation = OperationResult<CreateCandyMachineInput, OperationError>

class CreateCandyMachineOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = CreateCandyMachineInput
    typealias O = CandyMachine

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: CreateCandyMachineOperation) -> OperationResult<CandyMachine, OperationError> {
        operation.flatMap { input in
            self.createParametersFromInput(input).flatMap { [weak self] parameters in
                guard let self else { return .failure(.nilOperationHandler) }
                return self.createOperationResult(parameters)
            }.mapError {
                return $0
            }
        }
    }

    // MARK: - Private Helpers

    private func createParametersFromInput(
        _ input: CreateCandyMachineInput
    ) -> OperationResult<CreateCandyMachineBuilderParameters, OperationError> {
        OperationResult<CreateCandyMachineBuilderParameters, OperationError>.init { [weak self] callback in
            guard let self else {
                callback(.failure(.nilOperationHandler))
                return
            }
            
            self.metaplex.connection.getCreatingTokenAccountFee(space: input.accountSize) { result in
                switch result {
                case .success(let lamports):
                    let parameters = CreateCandyMachineBuilderParameters(
                        createCandyMachineInput: input,
                        defaultIdentity: self.metaplex.identity(),
                        lamports: lamports
                    )
                    callback(.success(parameters))
                case .failure(let error):
                    callback(.failure(OperationError.couldNotGetLamports(error)))
                }
            }
        }
    }

    private func createOperationResult(
        _ parameters: CreateCandyMachineBuilderParameters
    ) -> OperationResult<CandyMachine, OperationError> {
        let CreateCandyMachineBuilder = TransactionBuilder.createCandyMachineBuilder(parameters: parameters)
        let operation = OperationResult<SignatureStatus, OperationError>.init { callback in
            CreateCandyMachineBuilder.sendAndConfirm(metaplex: self.metaplex) { result in
                switch result {
                case .success(let status):
                    callback(.success(status))
                case .failure(let error):
                    callback(.failure(.confirmTransactionError(error)))
                }
            }
        }.flatMap { _ in
            OperationResult<CandyMachine, OperationError>.init { callback in
                self.metaplex.candyMachine.findByAddress(parameters.candyMachine) {
                    callback($0)
                }
            }
        }
        return operation
    }
}
