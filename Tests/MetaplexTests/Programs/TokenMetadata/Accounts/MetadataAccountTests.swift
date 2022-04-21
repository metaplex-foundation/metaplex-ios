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
    
}
