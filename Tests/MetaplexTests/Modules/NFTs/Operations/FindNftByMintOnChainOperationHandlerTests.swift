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
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.solanaRPC, publicKey: TEST_PUBLICKEY)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testFindNftByMintOnChainOperation(){
        var result: Result<NFT, OperationError>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftByMintOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftByMintOperation.pure(.success(PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        
        let nft = try! result?.get()
        XCTAssertNotNil(nft)
        XCTAssertEqual(nft!.metadataAccount.data.name, "Aurorian #628")
        XCTAssertEqual(nft!.metadataAccount.mint.base58EncodedString, "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")
        XCTAssertEqual(nft!.metadataAccount.data.creators.count, 3)
        XCTAssertEqual(nft!.masterEditionAccount?.type, 6)
        
        switch nft!.masterEditionAccount!.masterEditionVersion {
        case .masterEditionV1(_):
            XCTFail()
        case .masterEditionV2(let masterEditionV1):
            XCTAssertEqual(masterEditionV1.maxSupply, 0)
        }
    }
}
