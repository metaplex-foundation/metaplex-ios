//
//  FindNftByMintOnChainOperationTests.swift
//  
//
//  Created by Arturo Jamaica on 4/13/22.
//

import Foundation
import XCTest
import Solana
@testable import Metaplex

final class FindNftByMintOnChainOperationTests: XCTestCase {
    var metaplex: Metaplex!
    
    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.solanaRPC, publicKey: PublicKey(string: TEST_PUBLICKEY)!)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testFindAddress() {
        let seedMetadata = ["metadata".bytes,
                            PublicKey(string: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s")!.bytes,
                            PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!.bytes].map { Data($0) }
        
        let metadatakey = try! PublicKey.findProgramAddress(seeds: seedMetadata, programId: PublicKey(string: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s")!).get()
        XCTAssertEqual(metadatakey.0.base58EncodedString, "Hxi2SYmviCkzDF3NY1Ph3gUhwPiN4iGGTg2wK2PS2haQ")
    }
    
    func testFindNftByMintOnChainOperation(){
        var result: Result<NFT, OperationError>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftByMintOnChainOperation(metaplex: self!.metaplex)
            operation.handle(operation: FindNftByMintOperation.pure(.success(PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        let nft = try! result?.get()
        XCTAssertNotNil(nft)
        XCTAssertEqual(nft?.mint.base58EncodedString, "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")
    }
}
