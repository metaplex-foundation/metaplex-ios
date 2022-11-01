//
//  FindNftByTokenOnChainOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/27/22.
//

import Foundation
import Solana
import XCTest

@testable import Metaplex

final class FindNftByTokenOnChainOperationTests: XCTestCase {
    var metaplex: Metaplex!

    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .devnetSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.api, publicKey: PublicKey(string: "5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx")!)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }

    func testFindNftByTokenOnChainOperation() {
        var result: Result<NFT, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftByTokenOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftByTokenOperation.pure(.success(PublicKey(string: "9UDegF55fXmxYXiaPcrJWvonGepfLewiY4cr8CjouhLQ")!))).run {
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
