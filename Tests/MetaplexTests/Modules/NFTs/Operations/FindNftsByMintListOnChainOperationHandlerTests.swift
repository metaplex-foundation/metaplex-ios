//
//  FindNftsByMintListOnChainOperationHandler.swift
//  
//
//  Created by Arturo Jamaica on 4/18/22.
//

import Foundation
import XCTest
import Solana
@testable import Metaplex

class FindNftsByMintListOnChainOperationHandlerTests: XCTestCase {
    var metaplex: Metaplex!
    
    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.solanaRPC, publicKey: TEST_PUBLICKEY)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testFindNftByMintListOnChainOperation(){
        var result: Result<[NFT?], OperationError>?
        let lock = RunLoopSimpleLock()
        
        lock.dispatch { [weak self] in
            let operation = FindNftsByMintListOnChainOperation(metaplex: self!.metaplex)
            operation.handle(operation: FindNftsByMintListOperation.pure(.success(
                [PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!]
            ))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        
        let nft = try! result?.get().first!
        XCTAssertNotNil(nft)
        XCTAssertEqual(nft!.metadataAccount.data.name, "Aurorian #628")
        XCTAssertEqual(nft!.metadataAccount.mint.base58EncodedString, "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")
    }
}
