//
//  KeypairIdentityDriverTests.swift
//  
//
//  Created by Arturo Jamaica on 4/17/22.
//

import Foundation

import XCTest
import Solana
@testable import Metaplex

let mnemonic = ["across", "start", "ancient", "solid", "bid", "sentence", "visit", "old", "have", "hobby", "magic", "bomb", "boring", "grunt", "rule", "extra", "place", "strong", "myth", "episode", "dinner", "thrive", "wave", "decide"]

final class KeypairIdentityDriverTests: XCTestCase {
    
    let account = HotAccount(phrase: mnemonic, derivablePath: .default)!
    let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
    var keypairIdentityDriver: KeypairIdentityDriver!
    
    override func setUp() async throws {
        keypairIdentityDriver = KeypairIdentityDriver(solanaRPC: solanaConnection.api, account: account)
    }
    
    func testSetUpKeypairIdentityDriver() {
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let keypairIdentityDriver = KeypairIdentityDriver(solanaRPC: solanaConnection.api, account: HotAccount(phrase: mnemonic, derivablePath: .default)!)
        XCTAssertEqual(keypairIdentityDriver.publicKey.base58EncodedString, "FJyTK5ggCyWaZoJoQ9YAeRokNZtHbN4UwzeSWa2HxNyy")
    }
    
    func testSendTransactionInstruction() {
        let expedtedSignedTransaction = "AYR/M1/2bhdxo/ZjaVLw/CpkkNvwFk+VeoWkxZYWYHn/FW853U3UqL+mFaI2iFPsFB2i6EQ1kkDY9q8Hm3hR1wkBAAEC1J5StK6hI4+ERBMKkBUsHeIzegza3Eb/t7dwtSG4Q9QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEBAgAADAIAAADoAwAAAAAAAA=="
        var expectedResult: Result<Transaction, IdentityDriverError>!
        let instruction = SystemProgram.transferInstruction(
            from: account.publicKey,
            to: account.publicKey,
            lamports: UInt64(1000)
        )
        
        let transaction = Transaction(
            feePayer: account.publicKey,
            instructions: [instruction],
            recentBlockhash: "130295746"
        )
        
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.keypairIdentityDriver.signTransaction(transaction: transaction) { result in
                expectedResult = result
                lock.stop()
            }

        }
        lock.run()
        var transactionResult = try! expectedResult.get()
        let serialized = try! transactionResult.serialize().get()
        XCTAssertEqual(serialized.base64EncodedString(), expedtedSignedTransaction)
    }
}
