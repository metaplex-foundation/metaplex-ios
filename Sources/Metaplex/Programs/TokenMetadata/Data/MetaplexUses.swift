//
//  MetaplexUses.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Foundation
import Solana

public enum UseMethod: UInt8, Codable {
    case burn
    case multiple
    case single
}

public struct MetaplexUses: BorshCodable, BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 18

    public let useMethod: UseMethod
    public let remaining: UInt64
    public let total: UInt64

    public init(useMethod: UseMethod, remaining: UInt64, total: UInt64) {
        self.useMethod = useMethod
        self.remaining = remaining
        self.total = total
    }

    public init(from reader: inout BinaryReader) throws {
        self.useMethod = try UseMethod(rawValue: UInt8.init(from: &reader)) ?? .single
        self.remaining = try .init(from: &reader)
        self.total = try .init(from: &reader)
    }

    public func serialize(to writer: inout Data) throws {
        try useMethod.rawValue.serialize(to: &writer)
        try remaining.serialize(to: &writer)
        try total.serialize(to: &writer)
    }
}
