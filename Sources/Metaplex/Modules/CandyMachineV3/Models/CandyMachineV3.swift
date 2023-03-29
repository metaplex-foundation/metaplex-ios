import CandyMachineCore
import Foundation
import Solana

public struct CandyMachineV3 {
    // MARK: - Initialization

    private let candyMachine: Candymachine
    let address: PublicKey

    public init(
        candyMachine: Candymachine,
        address: PublicKey
    ) {
        self.candyMachine = candyMachine
        self.address = address
    }

    // MARK: - Getters

    public var version: AccountVersion { candyMachine.version }
    public var tokenStandard: UInt8 { candyMachine.tokenStandard }
    public var features: [UInt8] { candyMachine.features }
    public var authority: PublicKey { candyMachine.authority }
    public var mintAuthority: PublicKey { candyMachine.mintAuthority }
    public var collectionMint: PublicKey { candyMachine.collectionMint }
    public var itemsRedeemed: UInt64 { candyMachine.itemsRedeemed }
    public var data: CandyMachineData { candyMachine.data }
}

extension Candymachine {
    static func getUuidFromAddress(_ address: PublicKey) -> String {
        String(address.base58EncodedString.prefix(6))
    }

    static func getAccountSizeFrom(_ data: CandyMachineData) -> UInt64 {
        data.hiddenSettings != nil ? UInt64(CONFIG_ARRAY_START) : UInt64(
            CONFIG_ARRAY_START
            + 4
            + Int(data.itemsAvailable) * CONFIG_LINE_SIZE
            + 8
            + 2 * (Int(data.itemsAvailable) / 8 + 1)
        )
    }

    static func pda(address: PublicKey) -> Result<Pda, Error> {
        let seeds = [
            "candy_machine".bytes,
            address.bytes,
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map {
            Pda(publicKey: $0.0, bump: $0.1)
        }
    }

    static func collectionPda(candyMachine: PublicKey) -> Result<Pda, Error> {
        let seeds = [
            "collection".bytes,
            candyMachine.bytes,
        ].map { Data($0) }
        return PublicKey.findProgramAddress(seeds: seeds, programId: PROGRAM_ID!).map {
            Pda(publicKey: $0.0, bump: $0.1)
        }
    }
}
