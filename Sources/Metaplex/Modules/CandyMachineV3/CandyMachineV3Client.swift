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

public class CandyMachineV3Client {
    let metaplex: Metaplex
    
    public init(metaplex: Metaplex) {
        self.metaplex = metaplex
    }
    
    public func findByAddress(
        _ address: PublicKey,
        onComplete: @escaping (Result<CandyMachineV3, OperationError>) -> Void
    ) {
        let operation = FindCandyMachineV3ByAddressOperationHandler(metaplex: metaplex)
        operation.handle(operation: FindCandyMachineV3ByAddressOperation.pure(.success(address))).run { onComplete($0) }
    }
}
