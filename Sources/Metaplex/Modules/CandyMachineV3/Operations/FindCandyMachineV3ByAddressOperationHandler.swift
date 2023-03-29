//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 3/29/23.
//

import Foundation
import CandyMachineCore
import Foundation
import Solana

typealias FindCandyMachineV3ByAddressOperation = OperationResult<PublicKey, OperationError>

class FindCandyMachineV3ByAddressOperationHandler: OperationHandler {
    var metaplex: Metaplex

    typealias I = PublicKey
    typealias O = CandyMachineV3

    init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }

    func handle(operation: FindCandyMachineV3ByAddressOperation) -> OperationResult<CandyMachineV3, OperationError> {
        operation.flatMap { address in
            OperationResult<CandyMachineV3, Error>.init { callback in
                Candymachine.fromAccountAddress(connection: self.metaplex.connection.api, address: address) { result in
                    switch result {
                    case .success(let candyMachine):
                        callback(
                            .success(
                                CandyMachineV3(
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
