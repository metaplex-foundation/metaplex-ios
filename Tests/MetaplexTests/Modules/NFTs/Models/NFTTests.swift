//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 5/18/22.
//

import Foundation
import XCTest
import Solana
@testable import Metaplex

final class NFTTests: XCTestCase {
    var metaplex: Metaplex!
    
    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.solanaRPC, publicKey: TEST_PUBLICKEY)
        let storageDriver = URLSharedStorageDriver(urlSession: URLSession.shared)
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testsNFTmetadata() {
        var metadata: JsonMetadata? = nil
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftByMintOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftByMintOperation.pure(.success(PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!))).run {
                let nft = try! $0.get()
                nft.metadata(metaplex: self!.metaplex, onComplete: { result in
                    metadata = try! result.get()
                    lock.stop()
                })
            }
        }
        lock.run()
        XCTAssertEqual(metadata!.name, "Aurorian #628")
        XCTAssertEqual(metadata!.symbol, "AUROR")
        XCTAssertEqual(metadata!.seller_fee_basis_points, 500)
        XCTAssertEqual(metadata!.attributes![10].value, .number(1))
        
        XCTAssertEqual(metadata!.properties?.creators?.first?.address, "8Kag8CqNdCX55s4A5W4iraS71h6mv6uTHqsJbexdrrZm")
    }
}
