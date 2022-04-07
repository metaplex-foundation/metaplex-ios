import XCTest
import Solana
@testable import Metaplex

final class MetaplexTests: XCTestCase {
    func testSetUpMetaplex() {
        let solanaConnection = SolanaConnectionDriver(endpoint: .mainnetBetaSolana)
        let solanaIdentityDriver = SolanaIdentityDriver(solanaRPC: solanaConnection.solanaRPC, publicKey: PublicKey(string: "CN87nZuhnFdz74S9zn3bxCcd5ZxW55nwvgAv5C2Tz3K7")!)
        let storageDriver = MemoryStorageDriver()
        let metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
        XCTAssertNotNil(metaplex)
    }
}
