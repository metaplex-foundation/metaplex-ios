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
    var account: HotAccount!
    var mintAccount: HotAccount!
    var metaplex: Metaplex!

    override func setUpWithError() throws {
        let phrase: [String] = "siege amazing camp income refuse struggle feed kingdom lawn champion velvet crystal stomach trend hen uncover roast nasty until hidden crumble city bag minute".components(separatedBy: " ")
        account = HotAccount(phrase: phrase, network: .devnet)!
        mintAccount = HotAccount(network: .devnet)

        let solanaConnection = SolanaConnectionDriver(endpoint: .devnetSolana)
        let solanaIdentityDriver = KeypairIdentityDriver(solanaRPC: solanaConnection.api, account: account)
        let storageDriver = MemoryStorageDriver()

        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }

    func testCreateNftOnChainOperation() {
        let input = CreateNftInput(
            mintAccountState: .new(mintAccount),
            account: account,
            name: "Lil Foxy2009",
            symbol: "LF",
            uri: "https://bafybeig7fvs66jwfszmddy5ojxyjvitgs7sfoxlk3lz3qhclqmvqtfbi4y.ipfs.nftstorage.link/2009.json",
            sellerFeeBasisPoints: 660,
            hasCreators: true,
            addressCount: 1,
            creators: [.init(address: PublicKey(string: "Cf6C3xpvYNFx5qwq9Q7BczKcxTL5fRY5r3czg2sNDBfe")!, verified: 0, share: 100)],
            isMutable: true
        )

        var result: Result<NFT, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = CreateNftOnChainOperationHandler(metaplex: self.metaplex)
            operation.handle(operation: CreateNftOperation.pure(.success(input))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        guard let nft = try? result?.get() else {
            return XCTFail("NFT result is nil.")
        }

        XCTAssertNotNil(nft)
        XCTAssertEqual(nft.metadataAccount.data.name, "Lil Foxy2009")
        XCTAssertEqual(nft.metadataAccount.mint.base58EncodedString, mintAccount.publicKey.base58EncodedString)
        XCTAssertEqual(nft.metadataAccount.data.creators.count, 1)
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
