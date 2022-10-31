//
//  CreateNftOnChainOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Foundation
import XCTest
import Solana

@testable import Metaplex

final class CreateNftOnChainOperationTests: XCTestCase {
    func testCreateNftOnChainOperation() {
        let metaplex = TestDataProvider.createMetaplex()

        let account = HotAccount()!
        guard let nft = TestDataProvider.createNft(metaplex, mintAccount: .new(account)) else {
            return XCTFail("NFT result is nil.")
        }

        XCTAssertNotNil(nft)
        XCTAssertEqual(nft.metadataAccount.data.name, "Lil Foxy2009")
        XCTAssertEqual(nft.metadataAccount.mint.base58EncodedString, account.publicKey.base58EncodedString)
        XCTAssertEqual(nft.metadataAccount.data.creators.count, 0)
        XCTAssertEqual(nft.masterEditionAccount?.type, 6)

        guard let masterEditionAccount = nft.masterEditionAccount else {
            return XCTFail("MasterEditionAccount is nil.")
        }
        switch masterEditionAccount.masterEditionVersion {
        case .masterEditionV1(_):
            XCTFail()
        case .masterEditionV2(let masterEditionV2):
            XCTAssertEqual(masterEditionV2.maxSupply, 1)
        }
    }
}
