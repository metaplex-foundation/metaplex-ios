//
//  MasterEditionAccountTests.swift
//  
//
//  Created by Arturo Jamaica on 4/14/22.
//

import Foundation
import XCTest
import Solana
@testable import Metaplex

final class MasterEditionAccountTests: XCTestCase {
    func testFindAddress() {
        let mintKey = PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!
        let seedMetadata = [String.metadataPrefix.bytes,
                            PublicKey.metadataProgramId.bytes,
                            mintKey.bytes,
                            String.editionKeyword.bytes].map { Data($0) }
        
        let metadatakey = try! PublicKey.findProgramAddress(seeds: seedMetadata, programId: .metadataProgramId).get()
        
        let metadatakey2 = try! MasterEditionAccount.pda(mintKey: mintKey).get()
        XCTAssertEqual(metadatakey.0.base58EncodedString, metadatakey2.base58EncodedString)
    }
    
}
