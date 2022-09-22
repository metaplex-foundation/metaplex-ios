//
//  MasterEditionV1.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Beet
import Foundation
import Solana

public class MasterEditionV1: BufferLayout {
    public let supply: UInt64?
    public let maxSupply: UInt64?
    public let printingMint: PublicKey
    public let oneTimePrintingAuthorizationMint: PublicKey

    public static var BUFFER_LENGTH: UInt64 = 282

    public init(supply: UInt64?, maxSupply: UInt64?, printingMint: PublicKey, oneTimePrintingAuthorizationMint: PublicKey) {
        self.supply = supply
        self.maxSupply = maxSupply
        self.printingMint = printingMint
        self.oneTimePrintingAuthorizationMint = oneTimePrintingAuthorizationMint
    }

    required public init(from reader: inout BinaryReader) throws {
        self.supply = try? .init(from: &reader)
        self.maxSupply = try? .init(from: &reader)
        self.printingMint = try .init(from: &reader)
        self.oneTimePrintingAuthorizationMint = try .init(from: &reader)
    }

    public func serialize(to writer: inout Data) throws {
        try supply?.serialize(to: &writer)
        try maxSupply?.serialize(to: &writer)
        try printingMint.serialize(to: &writer)
        try oneTimePrintingAuthorizationMint.serialize(to: &writer)
    }
}
