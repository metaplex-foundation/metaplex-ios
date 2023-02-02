//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 4/22/22.
//

import Foundation
import XCTest
import Solana
@testable import Metaplex

final class FindNftsByOwnerOnChainOperationHandlerTests: XCTestCase {
    var metaplex: Metaplex!
    
    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .devnetSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.api, publicKey: TEST_PUBLICKEY)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testFindNftsByOwnerOperation(){
        var result: Result<[NFT?], OperationError>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftsByOwnerOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftsByOwnerOperation.pure(.success(TEST_PUBLICKEY))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        let nfts = try! result?.get()
        let nft = nfts!.first { $0!.metadataAccount.mint.base58EncodedString == "5quwyoKCi25TmamvqRDi373e1TgypCfnAKFR9h6KwB6G" }!
        XCTAssertEqual(nft?.uri, "https://arweave.net/8G_jZ4hY-96LGxK9aK1DY2Po6NTjVbiqXM339FuzLFM")
        XCTAssertEqual(nft?.updateAuthority.base58EncodedString, "ccc9XfyEMh9sU6DRkUmqQGJqgdKb6QyUaaT5h5BGYw4")
    }
}
