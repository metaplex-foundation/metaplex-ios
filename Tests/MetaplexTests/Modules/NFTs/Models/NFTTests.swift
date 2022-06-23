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
    
    func testsNFTonChain() {
        var nft: NFT? = nil
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftByMintOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftByMintOperation.pure(.success(PublicKey(string: "7A1R6HLKVEnu74kCM7qb59TpmJGyUX8f5t7p3FCrFTVR")!))).run {
                nft = try! $0.get()
                lock.stop()
            }
        }
        lock.run()
        XCTAssertEqual(nft!.name, "DeGod #5116")
        XCTAssertEqual(nft!.creators.first?.address.base58EncodedString, "9MynErYQ5Qi6obp4YwwdoDmXkZ1hYVtPUqYmJJ3rZ9Kn")
        XCTAssertEqual(nft!.primarySaleHappened, true)
        XCTAssertEqual(nft!.isMutable, true)
        XCTAssertEqual(nft!.editionNonce, 254)
        XCTAssertEqual(nft!.tokenStandard, MetaplexTokenStandard.NonFungible)
        XCTAssertNotNil(nft!.collection)
        XCTAssertEqual(nft!.collection?.key.base58EncodedString, "6XxjKYFbcndh2gDcsUrmZgVEsoDxXMnfsaGY6fpTJzNr")
    }
    
    func testsNFTonChain2() {
        var nft: NFT? = nil
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            let operation = FindNftByMintOnChainOperationHandler(metaplex: self!.metaplex)
            operation.handle(operation: FindNftByMintOperation.pure(.success(PublicKey(string: "GU6wXYYyCiXA2KMBd1e1eXttpK1mzjRPjK6rA2QD1fN2")!))).run {
                nft = try! $0.get()
                lock.stop()
            }
        }
        lock.run()
        XCTAssertEqual(nft!.name, "Degen Ape #6125")
        XCTAssertEqual(nft!.creators.first?.address.base58EncodedString, "9BKWqDHfHZh9j39xakYVMdr6hXmCLHH5VfCpeq2idU9L")
        XCTAssertEqual(nft!.primarySaleHappened, true)
        XCTAssertEqual(nft!.isMutable, false)
        XCTAssertEqual(nft!.editionNonce, 255)
        XCTAssertEqual(nft!.tokenStandard, MetaplexTokenStandard.NonFungible)
        XCTAssertNotNil(nft!.collection)
        XCTAssertEqual(nft!.collection?.key.base58EncodedString, "DSwfRF1jhhu6HpSuzaig1G19kzP73PfLZBPLofkw6fLD")
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
