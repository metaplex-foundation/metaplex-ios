//
//  FindAuctionHouseByAddressOperationHandlerTests.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/20/22.
//
/// All Auction House tests are set to run locally using `amman`, but are commented out so CI can pass. To run these tests you will need the [js sdk](git@github.com:metaplex-foundation/js.git). With the repo cloned, from the terminal run the following commands from the `js` directory:
///
/// ```
/// yarn install
/// yarn amman:start
/// ```

//import AuctionHouse
//import Foundation
//import Solana
//import XCTest
//
//@testable import Metaplex
//
//final class FindAuctionHouseByAddressOperationHandlerTests: XCTestCase {
//    var metaplex: Metaplex!
//
//    override func setUpWithError() throws {
//        let solanaConnection = SolanaConnectionDriver(endpoint: .devnetSolana)
//        let solanaIdentityDriver = ReadOnlyIdentityDriver(solanaRPC: solanaConnection.api, publicKey: TEST_PUBLICKEY)
//        let storageDriver = MemoryStorageDriver()
//        metaplex = Metaplex(connection: solanaConnection, identityDriver: solanaIdentityDriver, storageDriver: storageDriver)
//    }
//
//    func testFindAuctionHouseByAddressOperation() {
//        var result: Result<Auctionhouse, OperationError>?
//
//        let lock = RunLoopSimpleLock()
//        lock.dispatch { [weak self] in
//            let operation = FindAuctionHouseByAddressOperationHandler(metaplex: self!.metaplex)
//            operation.handle(operation: FindAuctionHouseByAddressOperation.pure(.success(AuctionHouseTestDataProvider.address))).run {
//                result = $0
//                lock.stop()
//            }
//        }
//        lock.run()
//
//        let auctionHouse = try! result?.get()
//        XCTAssertNotNil(auctionHouse)
//
//        let expectedAuctionHouse = AuctionHouseTestDataProvider.expectedAuctionHouse
//
//        XCTAssertEqual(auctionHouse!.auctionHouseFeeAccount, expectedAuctionHouse.auctionHouseFeeAccount)
//        XCTAssertEqual(auctionHouse!.auctionHouseTreasury, expectedAuctionHouse.auctionHouseTreasury)
//        XCTAssertEqual(auctionHouse!.treasuryWithdrawalDestination, expectedAuctionHouse.treasuryWithdrawalDestination)
//        XCTAssertEqual(auctionHouse!.feeWithdrawalDestination, expectedAuctionHouse.feeWithdrawalDestination)
//        XCTAssertEqual(auctionHouse!.treasuryMint, expectedAuctionHouse.treasuryMint)
//        XCTAssertEqual(auctionHouse!.authority, expectedAuctionHouse.authority)
//        XCTAssertEqual(auctionHouse!.creator, expectedAuctionHouse.creator)
//    }
//}
