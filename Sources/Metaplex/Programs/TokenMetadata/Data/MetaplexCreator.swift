//
//  MetaplexCreator.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Beet
import Foundation
import Solana

public struct MetaplexCreator: BorshCodable, BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 32 + 8 + 8

    public init(address: PublicKey, verified: UInt8, share: UInt8) {
        self.address = address
        self.verified = verified
        self.share = share
    }

    public let address: PublicKey
    public let verified: UInt8

    public let share: UInt8

    public init(from reader: inout BinaryReader) throws {
        self.address = try .init(from: &reader)
        self.verified = try .init(from: &reader)
        self.share = try .init(from: &reader)
    }

    public func serialize(to writer: inout Data) throws {
        try address.serialize(to: &writer)
        try verified.serialize(to: &writer)
        try share.serialize(to: &writer)
    }
}
