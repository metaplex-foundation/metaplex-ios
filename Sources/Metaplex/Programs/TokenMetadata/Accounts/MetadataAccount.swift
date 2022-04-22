//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 4/14/22.
//

import Foundation
import Solana

extension PublicKey {
    
    static let vaultProgramId = PublicKey(string:                                          "vau1zxA2LbssAUEF7Gpw91zMM1LvXrvpzJtmZ58rPsn")!
    
    static let auctionProgramId = PublicKey(string:                                             "auctxRXPeJoc4817jDhf4HbjnhEcr1cCXenosMhK5R8")!
    
    static let metaplexProgramId = PublicKey(string:                                                 "p1exdMJcjVao65QdewkaZRUnU6VPSXhus9n2GzWfh98")!
    
    static let systemProgramID =  PublicKey(string: "11111111111111111111111111111111")!
}

extension String {
    static let metadataPrefix = "metadata"
}

public struct MetadataAccount: BufferLayout {
    
    static func pda(mintKey: PublicKey) -> Result<PublicKey, Error>{
        let seedMetadata = [String.metadataPrefix.bytes,
                            TokenMetadataProgram.publicKey.bytes,
                            mintKey.bytes].map { Data($0) }
        
        return PublicKey.findProgramAddress(seeds: seedMetadata, programId: TokenMetadataProgram.publicKey).map { (publicKey, nonce) in
            return publicKey
        }
    }
    
    public static var BUFFER_LENGTH: UInt64 = 679
    
    public init(key: UInt8, updateAuthority: PublicKey, mint: PublicKey, data: MetaplexData, primarySaleHappened: Bool, isMutable: Bool, editionNonce: UInt8? = nil) {
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
    public let editionNonce: UInt8?
    
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
    
    public init(name: String, symbol: String, uri: String, sellerFeeBasisPoints: UInt16, hasCreators: Bool, addressCount: UInt32,  creators: Array<MetaplexCreator>) {
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
    public let creators: Array<MetaplexCreator>
    
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
        try name.serialize(to: &writer)
        try symbol.serialize(to: &writer)
        try uri.serialize(to: &writer)
        try sellerFeeBasisPoints.serialize(to: &writer)
        try creators.isEmpty.serialize(to: &writer)
        try creators.count.serialize(to: &writer)
        for creator in creators {
            try creator.serialize(to: &writer)
        }
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
