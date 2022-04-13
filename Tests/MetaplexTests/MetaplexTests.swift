import XCTest
import Solana
@testable import Metaplex

let TEST_PUBLICKEY = "CN87nZuhnFdz74S9zn3bxCcd5ZxW55nwvgAv5C2Tz3K7"
final class MetaplexTests: XCTestCase {
    
    var metaplex: Metaplex!
    
    override func setUpWithError() throws {
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.solanaRPC, publicKey: PublicKey(string: TEST_PUBLICKEY)!)
        let storageDriver = MemoryStorageDriver()
        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
    }
    
    func testSetUpMetaplex() {
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.solanaRPC, publicKey: PublicKey(string: TEST_PUBLICKEY)!)
        let storageDriver = MemoryStorageDriver()
        let metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
        XCTAssertNotNil(metaplex)
    }
    
    func testGetAccountInfo(){
        var result: Result<BufferInfo<AccountInfo>, Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.metaplex.getAccountInfo(account: TEST_PUBLICKEY, decodedTo: AccountInfo.self) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        XCTAssertNotNil(result)
    }
    
    func testGetMultipleAccounts(){
        var result: Result<[BufferInfo<AccountInfo>], Error>?
        let lock = RunLoopSimpleLock()
        lock.dispatch { [weak self] in
            self?.metaplex.getMultipleAccounts(accounts: [TEST_PUBLICKEY], decodedTo: AccountInfo.self) {
                result = $0
                lock.stop()
            }
        }
        lock.run()
        XCTAssertNotNil(result)
    }
}

