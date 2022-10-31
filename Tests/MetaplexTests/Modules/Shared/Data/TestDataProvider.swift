//
//  TestDataProvider.swift.swift
//  
//
//  Created by Michael J. Huber Jr. on 10/24/22.
//

import Foundation
import Solana

@testable import Metaplex

struct TestDataProvider {
    static func createMetaplex() -> Metaplex {
        let account = HotAccount()!
        let url = URL(string: "http://127.0.0.1:8899")!
        let connection = SolanaConnectionDriver(endpoint: .init(url: url, urlWebSocket: url, network: .testnet))
        let identityDriver = KeypairIdentityDriver(solanaRPC: connection.api, account: account)
        let storageDriver = MemoryStorageDriver()

        let metaplex = Metaplex(connection: connection, identityDriver: identityDriver, storageDriver: storageDriver)
        airDropFunds(metaplex)

        return metaplex
    }

    static func createNft(_ metaplex: Metaplex, mintAccount: AccountState) -> NFT? {
        let input = CreateNftInput(
            mintAccountState: mintAccount,
            account: metaplex.identity(),
            name: "Lil Foxy2009",
            symbol: "LF",
            uri: "https://bafybeig7fvs66jwfszmddy5ojxyjvitgs7sfoxlk3lz3qhclqmvqtfbi4y.ipfs.nftstorage.link/2009.json",
            sellerFeeBasisPoints: 660,
            hasCreators: false,
            addressCount: 0,
            creators: [],
            isMutable: true
        )

        var result: Result<NFT, OperationError>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            let operation = CreateNftOnChainOperationHandler(metaplex: metaplex)
            operation.handle(operation: CreateNftOperation.pure(.success(input))).run {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }

    @discardableResult
    static func airDropFunds(_ metaplex: Metaplex, account publicKey: PublicKey? = nil) -> String? {
        let account = publicKey ?? metaplex.identity().publicKey
        
        var result: Result<String, Error>?

        let lock = RunLoopSimpleLock()
        lock.dispatch {
            metaplex.connection.api.requestAirdrop(
                account: account.base58EncodedString,
                lamports: 1_000_000_000
            ) {
                result = $0
                lock.stop()
            }
        }
        lock.run()

        return try? result?.get()
    }
}
