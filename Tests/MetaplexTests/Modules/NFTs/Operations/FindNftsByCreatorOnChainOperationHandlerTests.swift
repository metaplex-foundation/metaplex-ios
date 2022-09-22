//
//  FindNftsByCreatorOnChainOperationHandlerTests.swift
//
//
//  Created by Arturo Jamaica on 4/13/22.
//

import Foundation
import XCTest
import Solana
@testable import Metaplex

final class FindNftsByCreatorOnChainOperationHandlerTests: XCTestCase {
    var metaplex: Metaplex!
    
    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.api, publicKey: TEST_PUBLICKEY)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testFindNftsByCreatorOperation(){
        var result: Result<[NFT?], OperationError>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftsByCreatorOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftsByCreatorOperation.pure(.success(
                FindNftsByCreatorInput(
                    creator: PublicKey(string: "9vwYtcJsH1MskNaixcjgNBnvBDkTBhyg25umod1rgMQL")!,
                    position: 1
                ))))
            .run {
                result = $0
                lock.stop()
            }
        }
        lock.run()
    }
}
