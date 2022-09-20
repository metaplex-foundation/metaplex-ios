//
//  File.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/12/22.
//

import Beet
import Foundation
import Solana

public struct MetaplexData: BorshCodable, BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 10

    public init(name: String, symbol: String, uri: String, sellerFeeBasisPoints: UInt16, hasCreators: Bool, addressCount: UInt32, creators: [MetaplexCreator]) {
        self.name = name
        self.symbol = symbol
        self.uri = uri
        self.sellerFeeBasisPoints = sellerFeeBasisPoints
        self.hasCreators = hasCreators
        self.addressCount = addressCount
        self.creators = creators
    }

    public let name: String
    public let symbol: String
    public let uri: String
    public let sellerFeeBasisPoints: UInt16
    public let hasCreators: Bool
    public let addressCount: UInt32
    public let creators: [MetaplexCreator]

    public init(from reader: inout BinaryReader) throws {
        self.name = try .init(from: &reader).trimmingCharacters(in: CharacterSet(charactersIn: "\0").union(.whitespacesAndNewlines))
        self.symbol = try .init(from: &reader).trimmingCharacters(in: CharacterSet(charactersIn: "\0").union(.whitespacesAndNewlines))
        self.uri = try .init(from: &reader).trimmingCharacters(in: CharacterSet(charactersIn: "\0").union(.whitespacesAndNewlines))
        self.sellerFeeBasisPoints = try .init(from: &reader)
        self.hasCreators = try .init(from: &reader)
        var creatorsArray: [MetaplexCreator] = []
        if self.hasCreators {
            let addressCount: UInt32 = try .init(from: &reader)
            for _ in 0..<addressCount {
                let creator: MetaplexCreator = try .init(from: &reader)
                creatorsArray.append(creator)
            }

        }
        self.addressCount = UInt32(creatorsArray.count)
        self.creators = creatorsArray
    }

    public func serialize(to writer: inout Data) throws {
        try name.padding(toLength: 32, withPad: "\0", startingAt: 0).serialize(to: &writer)
        try symbol.padding(toLength: 10, withPad: "\0", startingAt: 0).serialize(to: &writer)
        try uri.padding(toLength: 200, withPad: "\0", startingAt: 0).serialize(to: &writer)
        try sellerFeeBasisPoints.serialize(to: &writer)
        try hasCreators.serialize(to: &writer)
        if hasCreators {
            try UInt32(creators.count).serialize(to: &writer)
            for creator in creators {
                try creator.serialize(to: &writer)
            }
        }
    }
}
