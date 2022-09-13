//
//  MetaplexCollection.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Foundation
import Solana

public struct MetaplexCollection: BorshCodable, BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 10

    public let verified: Bool
    public let key: PublicKey

    public init(verified: Bool, key: PublicKey){
        self.verified = verified
        self.key = key
    }

    public init(from reader: inout BinaryReader) throws {
        self.verified = try .init(from: &reader)
        self.key = try .init(from: &reader)
    }

    public func serialize(to writer: inout Data) throws {
        try verified.serialize(to: &writer)
        try key.serialize(to: &writer)
    }
}
