//
//  CandyMachine.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/4/22.
//

import CandyMachine
import Foundation
import Solana

public struct CandyMachine {
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

    public var authority: PublicKey { candyMachine.authority }
    public var wallet: PublicKey { candyMachine.wallet }
    public var tokenMint: PublicKey? { candyMachine.tokenMint }
    public var collectionMint: PublicKey? { nil }
    public var price: UInt64 { candyMachine.data.price }
    public var symbol: String { candyMachine.data.symbol }
    public var sellerFeeBasisPoints: UInt16 { candyMachine.data.sellerFeeBasisPoints }
    public var isMutable: Bool { candyMachine.data.isMutable }
    public var retainAuthority: Bool { candyMachine.data.retainAuthority }
    public var goLiveDate: Int64? { candyMachine.data.goLiveDate }
    public var maxEditionSupply: UInt64 { candyMachine.data.maxSupply }
    public var itemsAvailable: UInt64 { candyMachine.data.itemsAvailable }
    public var endSettings: EndSettings? { candyMachine.data.endSettings }
    public var hiddenSettings: HiddenSettings? { candyMachine.data.hiddenSettings }
    public var whitelistMintSettings: WhitelistMintSettings? { candyMachine.data.whitelistMintSettings }
    public var gatekeeper: GatekeeperConfig? { candyMachine.data.gatekeeper }
    public var creators: [Creator] { candyMachine.data.creators }
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
