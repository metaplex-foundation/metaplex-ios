//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 4/14/22.
//

import Beet
import Foundation
import Solana

public struct MetadataAccount: BufferLayout {
    static func pda(mintKey: PublicKey) -> Result<PublicKey, Error> {
        let seedMetadata = [String.metadataPrefix.bytes,
                            TokenMetadataProgram.publicKey.bytes,
                            mintKey.bytes].map { Data($0) }

        return PublicKey.findProgramAddress(seeds: seedMetadata, programId: TokenMetadataProgram.publicKey).map { (publicKey, _) in
            return publicKey
        }
    }

    static func collectionAuthorityPda(
        mintKey: PublicKey,
        collectionAuthority: PublicKey
    ) -> Result<PublicKey, Error> {
        let seedMetadata = [
            String.metadataPrefix.bytes,
            TokenMetadataProgram.publicKey.bytes,
            mintKey.bytes
        ].map { Data($0) }

        return PublicKey.findProgramAddress(
            seeds: seedMetadata,
            programId: TokenMetadataProgram.publicKey
        ).map { (publicKey, _) in
            return publicKey
        }
    }

    public static var BUFFER_LENGTH: UInt64 = 679

    public init(
        key: UInt8,
        updateAuthority: PublicKey,
        mint: PublicKey,
        data: MetaplexData,
        primarySaleHappened: Bool,
        isMutable: Bool,
        editionNonce: UInt8? = nil,
        tokenStandard: MetaplexTokenStandard? = nil,
        collection: MetaplexCollection? = nil
    ) {
        self.key = key
        self.updateAuthority = updateAuthority
        self.mint = mint
        self.data = data
        self.primarySaleHappened = primarySaleHappened
        self.isMutable = isMutable
        self.editionNonce = editionNonce
        self.tokenStandard = tokenStandard
        self.collection = collection
    }
    

    public let key: UInt8
    public let updateAuthority: PublicKey
    public let mint: PublicKey
    public let data: MetaplexData
    public let primarySaleHappened: Bool
    public let isMutable: Bool
    public let editionNonce: UInt8?
    public let tokenStandard: MetaplexTokenStandard?
    public let collection: MetaplexCollection?

    public init(from reader: inout BinaryReader) throws {
        self.key = try .init(from: &reader)
        self.updateAuthority = try .init(from: &reader)
        self.mint = try .init(from: &reader)
        self.data = try .init(from: &reader)
        self.primarySaleHappened = try .init(from: &reader)
        self.isMutable = try .init(from: &reader)
        let hasEditionNonce: Bool = try .init(from: &reader)
        if hasEditionNonce {
            self.editionNonce = try? .init(from: &reader)
        } else {
            self.editionNonce = nil
        }
        self.tokenStandard = try? MetaplexTokenStandard(rawValue: UInt8.init(from: &reader))
        let hasCollection: Bool = try .init(from: &reader)
        if hasCollection {
            self.collection = try? .init(from: &reader)
        } else {
            self.collection = nil
        }
    }

    public func serialize(to writer: inout Data) throws {
        try key.serialize(to: &writer)
        try updateAuthority.serialize(to: &writer)
        try mint.serialize(to: &writer)
        try data.serialize(to: &writer)
        try primarySaleHappened.serialize(to: &writer)
        try isMutable.serialize(to: &writer)

        let hasEditionNonce = editionNonce != nil
        try hasEditionNonce.serialize(to: &writer)
        if hasEditionNonce { try editionNonce?.serialize(to: &writer) }

        if let tokenStandard = tokenStandard {
            try tokenStandard.rawValue.serialize(to: &writer)
        } else {
            try UInt8(0).serialize(to: &writer)
        }

        let hasCollection = collection != nil
        try hasCollection.serialize(to: &writer)
        if hasCollection { try collection?.serialize(to: &writer) }

        let padding = MetadataAccount.BUFFER_LENGTH - UInt64(writer.bytes.count)
        try (0..<padding).forEach { _ in
            try UInt8(0).serialize(to: &writer)
        }
    }
}
