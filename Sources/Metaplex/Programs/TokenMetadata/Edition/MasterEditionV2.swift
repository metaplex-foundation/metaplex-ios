//
//  MasterEditionV2.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Foundation
import Solana

public class MasterEditionV2: BufferLayout {
    public let supply: UInt64
    public let maxSupply: UInt64?

    public static var BUFFER_LENGTH: UInt64 = 282

    public init(supply: UInt64, maxSupply: UInt64?) {
        self.supply = supply
        self.maxSupply = maxSupply
    }

    required public init(from reader: inout BinaryReader) throws {
        self.supply = try .init(from: &reader)

        let hasMaxSupply: Bool = try .init(from: &reader)
        if hasMaxSupply {
            self.maxSupply = try? .init(from: &reader)
        } else {
            self.maxSupply = nil
        }
    }

    public func serialize(to writer: inout Data) throws {
        try supply.serialize(to: &writer)

        let hasMaxSupply = maxSupply != nil
        if hasMaxSupply { try maxSupply?.serialize(to: &writer) }
    }
}
