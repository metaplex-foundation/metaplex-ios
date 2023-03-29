//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 3/29/23.
//

import Foundation
import Solana
import XCTest

@testable import Metaplex

final class FindCandyMachineV3ByAddressOperationTests: XCTestCase {
    
    var metaplex: Metaplex!

    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.api, publicKey: PublicKey(string: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx")!)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testFindCandyMachineV3Operation() {
        var result: Result<CandyMachineV3, OperationError>!
        

        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindCandyMachineV3ByAddressOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindCandyMachineV3ByAddressOperation.pure(.success(PublicKey(string: "3Nd6KpZYBUsHR2kXkzuWTBnxDdfqsnKHUHs3QDD1ijNC")!))).run {
                result = $0
                lock.stop()
                let candyMachine = try! result.get()
                XCTAssertEqual(candyMachine.address, PublicKey(string: "3Nd6KpZYBUsHR2kXkzuWTBnxDdfqsnKHUHs3QDD1ijNC"))
                XCTAssertEqual(candyMachine.tokenStandard, 0)
                XCTAssertEqual(candyMachine.itemsRedeemed, 8)
            }
        }
        lock.run()
        
    }
}
