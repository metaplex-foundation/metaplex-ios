//
//  FindNftByMintOnChainOperationTests.swift
//  
//
//  Created by Arturo Jamaica on 4/13/22.
//

import Foundation
import XCTest
import Solana
import TweetNacl
@testable import Metaplex

final class FindNftByMintOnChainOperationTests: XCTestCase {
    var metaplex: Metaplex!
    
    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .init(url: URL(string: "http://127.0.0.1:8899")!, urlWebSocket: URL(string: "http://127.0.0.1:8899")!, network: .testnet))
        let data = try? NaclSign.KeyPair.keyPair()
        let publicKey = PublicKey(data: data!.publicKey)!
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.api, publicKey: publicKey)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testFindNftByMintOnChainOperation(){
        var result: Result<NFT, OperationError>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftByMintOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftByMintOperation.pure(.success(PublicKey(string: "VHy8GJ33ijRVARp3wpvcmFMhm3zepm7gdQupuqLA1gH")!))).run {
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
