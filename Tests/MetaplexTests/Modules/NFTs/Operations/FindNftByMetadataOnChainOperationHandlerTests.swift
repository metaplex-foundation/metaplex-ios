//
//  FindNftByMetadataOnChainOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/28/22.
//

import Foundation
import Solana
import XCTest

@testable import Metaplex

final class FindNftByMetadataOnChainOperationHandlerTests: XCTestCase {
    var metaplex: Metaplex!

    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .devnetSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.api, publicKey: PublicKey(string: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx")!)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }

    func testFindNftByMetadataOnChainOperation() {
        var result: Result<NFT, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftByMetadataOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftByMetadataOperation.pure(.success(PublicKey(string: "DM5HwF7mxCcqrphBxC2AYoZTdzWg4BMxQthpDRy5Pjyj")!))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        let nft = try? result?.get()
        XCTAssertNotNil(nft)

        XCTAssertEqual(nft?.metadataAccount.data.name, "Lil Foxy2009")
        XCTAssertEqual(nft?.metadataAccount.mint.base58EncodedString, "CToJ7xaJETpYqMLb1FVSMV1Lr83SgGYiqCwsKKguvDxy")
    }
}
