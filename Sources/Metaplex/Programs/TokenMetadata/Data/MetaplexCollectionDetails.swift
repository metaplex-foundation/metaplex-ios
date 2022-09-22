//
//  MetaplexCollectionDetails.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Beet
import Foundation
import Solana

// NOTE: This will be fixed later.
public struct MetaplexCollectionDetails: BorshCodable, BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 10

    public let version: String
    public let size: UInt64

    public init(version: String, size: UInt64) {
        self.version = version
        self.size = size
    }

    public init(from reader: inout BinaryReader) throws {
        self.version = try .init(from: &reader)
        self.size = try .init(from: &reader)
    }

    public func serialize(to writer: inout Data) throws {
        try version.serialize(to: &writer)
        try size.serialize(to: &writer)
    }
}
