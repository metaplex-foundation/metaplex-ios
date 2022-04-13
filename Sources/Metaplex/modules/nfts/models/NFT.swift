//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 4/11/22.
//

import Foundation
import Solana

public struct NFT: BorshCodable, BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 679
    
    public init(key: UInt8, updateAuthority: PublicKey, mint: PublicKey, data: MetaplexData, primarySaleHappened: Bool, isMutable: Bool, editionNonce: UInt64? = nil) {
        self.key = key
        self.updateAuthority = updateAuthority
        self.mint = mint
        self.data = data
        self.primarySaleHappened = primarySaleHappened
        self.isMutable = isMutable
        self.editionNonce = editionNonce
    }
    
    public let key: UInt8
    public let updateAuthority: PublicKey
    public let mint: PublicKey
    public let data: MetaplexData
    public let primarySaleHappened: Bool
    public let isMutable: Bool
    public let editionNonce: UInt64?
    
    public init(from reader: inout BinaryReader) throws {
        self.key = try .init(from: &reader)
        self.updateAuthority = try .init(from: &reader)
        self.mint = try .init(from: &reader)
        self.data = try .init(from: &reader)
        self.primarySaleHappened = try .init(from: &reader)
        self.isMutable = try .init(from: &reader)
        self.editionNonce = try? .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try key.serialize(to: &writer)
        try updateAuthority.serialize(to: &writer)
        try mint.serialize(to: &writer)
        try data.serialize(to: &writer)
        try primarySaleHappened.serialize(to: &writer)
        try isMutable.serialize(to: &writer)
        try editionNonce?.serialize(to: &writer)
    }
}

public struct MetaplexData: BorshCodable, BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 10
    
    public init(name: String, symbol: String, uri: String, sellerFeeBasisPoints: UInt16) {
        self.name = name
        self.symbol = symbol
        self.uri = uri
        self.sellerFeeBasisPoints = sellerFeeBasisPoints
        //self.creators = creators
    }
    
    public let name: String
    public let symbol: String
    public let uri: String
    public let sellerFeeBasisPoints: UInt16
    //public let creators: [MetaplexCreator]
    
    public init(from reader: inout BinaryReader) throws {
        self.name = try .init(from: &reader)
        self.symbol = try .init(from: &reader)
        self.uri = try .init(from: &reader)
        self.sellerFeeBasisPoints = try .init(from: &reader)
        //self.creators = try .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try name.serialize(to: &writer)
        try symbol.serialize(to: &writer)
        try uri.serialize(to: &writer)
        try sellerFeeBasisPoints.serialize(to: &writer)
        //try creators.serialize(to: &writer)
    }
}

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
