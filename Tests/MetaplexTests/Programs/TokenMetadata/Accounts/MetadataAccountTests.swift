//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 4/14/22.
//

import Foundation
import XCTest
import Solana
@testable import Metaplex

final class MetadataAccountTests: XCTestCase {
    func testFindAddress() {
        let mintKey = PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!
        let seedMetadata = [String.metadataPrefix.bytes,
                            TokenMetadataProgram.publicKey.bytes,
                            mintKey.bytes].map { Data($0) }
        
        let metadatakey = try! PublicKey.findProgramAddress(seeds: seedMetadata, programId: TokenMetadataProgram.publicKey).get()
        
        let metadatakey2 = try! MetadataAccount.pda(mintKey: mintKey).get()
        XCTAssertEqual(metadatakey.0.base58EncodedString, metadatakey2.base58EncodedString)
    }

    func testMetadataAccountWithNonNftAccount() {
        let connection = SolanaConnectionDriver(endpoint: .devnetSolana)

        var result: Result<BufferInfo<MetadataAccount>, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let mintKey = PublicKey(string: "5xN42RZCk7wA4GjQU2VVDhda8LBL8fAnrKZK921sybLF")!
            let publicKey = try! MetadataAccount.pda(mintKey: mintKey).get()
            connection.getAccountInfo(account: publicKey, decodedTo: MetadataAccount.self) {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        if case .failure(SolanaError.nullValue) = result {
            XCTAssert(true)
        } else {
            XCTFail("Should be null value because it's a non Metadata account.")
        }
    }

    func testMetadataAccountSerialization() {
        let connection = Api(router: NetworkingRouter(endpoint: .mainnetBetaSolana), supportedTokens: [])

        var result: Result<BufferInfoPureData, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let pk = try! MetadataAccount.pda(mintKey: PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!).get()
            connection.getAccountInfo(account: pk.base58EncodedString) { r in
                result = r
                lock.stop()
            }
        }
        lock.run()

        let metadataPureData = try! result!.get().data!.value!
        var metadataReader = BinaryReader(bytes: metadataPureData.bytes)
        let metadataFromReader = try! MetadataAccount(from: &metadataReader)

        var metadataSerialized = Data()
        try! metadataFromReader.serialize(to: &metadataSerialized)

        var metadataSerializedReader = BinaryReader(bytes: metadataSerialized.bytes)
        let metadataFromSerializedReader = try! MetadataAccount(from: &metadataSerializedReader)

        XCTAssertEqual(metadataPureData.bytes, metadataSerialized.bytes)

        XCTAssertEqual(metadataFromReader.key, metadataFromSerializedReader.key)
        XCTAssertEqual(metadataFromReader.updateAuthority, metadataFromSerializedReader.updateAuthority)
        XCTAssertEqual(metadataFromReader.mint, metadataFromSerializedReader.mint)

        XCTAssertEqual(metadataFromReader.data.name, metadataFromSerializedReader.data.name)
        XCTAssertEqual(metadataFromReader.data.symbol, metadataFromSerializedReader.data.symbol)
        XCTAssertEqual(metadataFromReader.data.uri, metadataFromSerializedReader.data.uri)
        XCTAssertEqual(metadataFromReader.data.sellerFeeBasisPoints, metadataFromSerializedReader.data.sellerFeeBasisPoints)
        XCTAssertEqual(metadataFromReader.data.hasCreators, metadataFromSerializedReader.data.hasCreators)
        XCTAssertEqual(metadataFromReader.data.addressCount, metadataFromSerializedReader.data.addressCount)
        XCTAssertEqual(metadataFromReader.data.creators.count, metadataFromSerializedReader.data.creators.count)

        XCTAssertEqual(metadataFromReader.primarySaleHappened, metadataFromSerializedReader.primarySaleHappened)
        XCTAssertEqual(metadataFromReader.isMutable, metadataFromSerializedReader.isMutable)
        XCTAssertEqual(metadataFromReader.editionNonce, metadataFromSerializedReader.editionNonce)
        XCTAssertEqual(metadataFromReader.tokenStandard, metadataFromSerializedReader.tokenStandard)

        XCTAssertEqual(metadataFromReader.collection?.verified, metadataFromSerializedReader.collection?.verified)
        XCTAssertEqual(metadataFromReader.collection?.key, metadataFromSerializedReader.collection?.key)
    }
}
