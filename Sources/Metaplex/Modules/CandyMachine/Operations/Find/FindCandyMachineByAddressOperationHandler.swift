//
//  FindCandyMachineByAddressOperationHandler.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/3/22.
//

import CandyMachine
import Foundation
import Solana

typealias FindCandyMachineByAddressOperation = OperationResult<PublicKey, OperationError>

class FindCandyMachineByAddressOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = PublicKey
    typealias O = CandyMachine

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindCandyMachineByAddressOperation) -> OperationResult<CandyMachine, OperationError> {
        operation.flatMap { address in
            OperationResult<CandyMachine, Error>.init { callback in
                Candymachine.fromAccountAddress(connection: self.metaplex.connection.api, address: address) { result in
                    switch result {
                    case .success(let candyMachine):
                        callback(
                            .success(
                                CandyMachine(
                                    candyMachine: candyMachine,
                                    address: address
                                )
                            )
                        )
                    case .failure(let error):
                        callback(.failure(error))
                    }
                }
            }
            .mapError { OperationError.findCandyMachineByAddressError($0) }
        }
    }
}
