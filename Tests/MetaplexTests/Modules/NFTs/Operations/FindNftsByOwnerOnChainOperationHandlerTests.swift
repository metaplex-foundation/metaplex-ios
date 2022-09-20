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
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.api, publicKey: TEST_PUBLICKEY)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testFindNftsByOwnerOperation(){
        var result: Result<[NFT?], OperationError>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftsByOwnerOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftsByOwnerOperation.pure(.success(PublicKey(string: "Geh5Ss5knQGym81toYGXDbH3MFU2JCMK7E4QyeBHor1b")!))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        let nfts = try! result?.get()
        let nft = nfts!.first { $0!.metadataAccount.mint.base58EncodedString == "71PdnsexRQG92ZcSpEV8nn5XFqPzfK5j86yUWRF5NLyp" }!
        XCTAssertEqual(nft?.uri, "https://arweave.net/UnB9UYQSwO3rGWSlQkwaiVDfKJOjPopV_IdWSqlLKlo")
        XCTAssertEqual(nft?.updateAuthority.base58EncodedString, "AVgijgTG4WKDycFwYhqioMreXJpz14no8dbE8EF5roZV")
    }
}
