//
//  MasterEditionAccount.swift
//  
//
//  Created by Arturo Jamaica on 4/14/22.
//

import Foundation
import Solana

extension String {
    static let editionKeyword = "edition"
}

public enum MetadataKey {
    case Uninitialized // 0
    case EditionV1 // 1
    case MasterEditionV1 // 2
    case ReservationListV1 // 3
    case MetadataV1 //4,
    case ReservationListV2 // 5
    case MasterEditionV2 //6,
    case EditionMarker //7
    case UseAuthorityRecord //8
    case CollectionAuthorityRecord // 9
    
    func value() -> UInt8 {
        switch self {
            
        case .Uninitialized:
            return 0
        case .EditionV1:
            return 1
        case .MasterEditionV1:
            return 2
        case .ReservationListV1:
            return 3
        case .MetadataV1:
            return 4
        case .ReservationListV2:
            return 5
        case .MasterEditionV2:
            return 6
        case .EditionMarker:
            return 7
        case .UseAuthorityRecord:
            return 8
        case .CollectionAuthorityRecord:
            return 9
        }
    }
}

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
        self.maxSupply = try? .init(from: &reader)
    }
    
    public func serialize(to writer: inout Data) throws {
        try supply.serialize(to: &writer)
        try maxSupply?.serialize(to: &writer)
    }
}

public enum MasterEditionVersion: Codable {
    case masterEditionV1(MasterEditionV1)
    case masterEditionV2(MasterEditionV2)
}

public class MasterEditionAccount: BufferLayout {
    
    static func pda(mintKey: PublicKey) -> Result<PublicKey, Error>{
        let seedMetadata = [String.metadataPrefix.bytes,
                            TokenMetadataProgram.publicKey.bytes,
                            mintKey.bytes,
                            String.editionKeyword.bytes].map { Data($0) }
        
        return PublicKey.findProgramAddress(seeds: seedMetadata, programId: TokenMetadataProgram.publicKey).map { (publicKey, nonce) in
            return publicKey
        }
    }
    
    public let type: UInt8
    public let masterEditionVersion: MasterEditionVersion
    
    public static var BUFFER_LENGTH: UInt64 = 282
    
    public init(type: UInt8, masterEditionVersion: MasterEditionVersion) {
        self.type = type
        self.masterEditionVersion = masterEditionVersion
    }
    
    required public init(from reader: inout BinaryReader) throws {
        self.type = try .init(from: &reader)
        if(self.type == MetadataKey.MasterEditionV1.value()){
            let masterEditionV1 = try MasterEditionV1.init(from: &reader)
            masterEditionVersion = .masterEditionV1(masterEditionV1)
        } else {
            let masterEditionV2 = try MasterEditionV2.init(from: &reader)
            masterEditionVersion = .masterEditionV2(masterEditionV2)
        }
    }
    public func serialize(to writer: inout Data) throws {
        try type.serialize(to: &writer)
        switch masterEditionVersion {
        case .masterEditionV1(let masterEditionV1):
            try masterEditionV1.serialize(to: &writer)
        case .masterEditionV2(let masterEditionV2):
            try masterEditionV2.serialize(to: &writer)
        }
    }
}
