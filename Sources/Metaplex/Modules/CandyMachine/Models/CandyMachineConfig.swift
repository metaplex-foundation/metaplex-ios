//
//  CandyMachineConfig.swift
//  
//
//  Created by Michael J. Huber Jr. on 11/4/22.
//

import CandyMachine
import Foundation
import Solana

public enum CreatorState {
    case creators([Creator])
    case creator(PublicKey)

    var creators: [Creator] {
        switch self {
        case .creators(let creators):
            return creators
        case .creator(let address):
            return [Creator(address: address, verified: false, share: 100)]
        }
    }
}

public struct CandyMachineConfig {
    let price: UInt64
    let sellerFeeBasisPoints: UInt16
    let itemsAvailable: UInt64
    let symbol: String
    let maxEditionSupply: UInt64
    let isMutable: Bool
    let retainAuthority: Bool
    let goLiveDate: Int64?
    let endSettings: EndSettings?
    let hiddenSettings: HiddenSettings?
    let whitelistMintSettings: WhitelistMintSettings?
    let gatekeeper: GatekeeperConfig?
    let creatorState: CreatorState

    public init(
        price: UInt64,
        sellerFeeBasisPoints: UInt16,
        itemsAvailable: UInt64,
        symbol: String = "",
        maxEditionSupply: UInt64 = 0,
        isMutable: Bool = true,
        retainAuthority: Bool = true,
        goLiveDate: Int64? = nil,
        endSettings: EndSettings? = nil,
        hiddenSettings: HiddenSettings? = nil,
        whitelistMintSettings: WhitelistMintSettings? = nil,
        gatekeeper: GatekeeperConfig? = nil,
        creatorState: CreatorState
    ) {
        self.price = price
        self.sellerFeeBasisPoints = sellerFeeBasisPoints
        self.itemsAvailable = itemsAvailable
        self.symbol = symbol
        self.maxEditionSupply = maxEditionSupply
        self.isMutable = isMutable
        self.retainAuthority = retainAuthority
        self.goLiveDate = goLiveDate
        self.endSettings = endSettings
        self.hiddenSettings = hiddenSettings
        self.whitelistMintSettings = whitelistMintSettings
        self.gatekeeper = gatekeeper
        self.creatorState = creatorState
    }
}

extension CandyMachineData {
    init(address: PublicKey, config: CandyMachineConfig) {
        self.init(
            uuid: Candymachine.getUuidFromAddress(address),
            price: config.price,
            symbol: config.symbol,
            sellerFeeBasisPoints: config.sellerFeeBasisPoints,
            maxSupply: config.maxEditionSupply,
            isMutable: config.isMutable,
            retainAuthority: config.retainAuthority,
            goLiveDate: config.goLiveDate,
            endSettings: config.endSettings,
            creators: config.creatorState.creators,
            hiddenSettings: config.hiddenSettings,
            whitelistMintSettings: config.whitelistMintSettings,
            itemsAvailable: config.itemsAvailable,
            gatekeeper: config.gatekeeper
        )
    }
}
