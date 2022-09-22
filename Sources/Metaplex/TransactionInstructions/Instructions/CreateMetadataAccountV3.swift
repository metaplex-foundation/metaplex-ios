//
//  CreateMetadataAccountV3.swift
//
//
//  Created by Michael J. Huber Jr. on 8/30/22.
//

import Beet
import Foundation
import Solana

public struct CreateMetadataAccountV3InstructionAccounts {
    let metadata: PublicKey
    let mint: PublicKey
    let mintAuthority: PublicKey
    let payer: PublicKey
    let updateAuthority: PublicKey
    let systemProgram: PublicKey?
    let rent: PublicKey?
}

public struct CreateMetadataAccountV3InstructionData: BorshCodable, BufferLayout {
    public static var BUFFER_LENGTH: UInt64 = 10

    public let data: MetaplexDataV2
    public let isMutable: Bool
    public let collectionDetails: MetaplexCollectionDetails?

    public init(data: MetaplexDataV2, isMutable: Bool, collectionDetails: MetaplexCollectionDetails?) {
        self.data = data
        self.isMutable = isMutable
        self.collectionDetails = collectionDetails
    }

    public init(from reader: inout BinaryReader) throws {
        self.data = try .init(from: &reader)
        self.isMutable = try .init(from: &reader)
        self.collectionDetails = try .init(from: &reader)
    }

    public func serialize(to writer: inout Data) throws {
        try data.serialize(to: &writer)
        try isMutable.serialize(to: &writer)
        try collectionDetails?.serialize(to: &writer)
    }
}

struct SignMetadataInstructionAccounts {
    let metadata: PublicKey
    let creator: PublicKey
}

public struct CreateMetadataAccountV3 {
    private struct Index {
        static let create: UInt8 = 33
        static let signMetadata: UInt8 = 7
    }

    static func createMetadataAccountV3Instruction(
        accounts: CreateMetadataAccountV3InstructionAccounts,
        arguments: CreateMetadataAccountV3InstructionData,
        programId: PublicKey = TokenMetadataProgram.publicKey
    ) -> TransactionInstruction {
        let keys = [
            Account.Meta(publicKey: accounts.metadata, isSigner: false, isWritable: true),
            Account.Meta(publicKey: accounts.mint, isSigner: false, isWritable: false),
            Account.Meta(publicKey: accounts.mintAuthority, isSigner: true, isWritable: false),
            Account.Meta(publicKey: accounts.payer, isSigner: true, isWritable: true),
            Account.Meta(publicKey: accounts.updateAuthority, isSigner: false, isWritable: false),
            Account.Meta(publicKey: accounts.systemProgram ?? PublicKey.systemProgramId, isSigner: false, isWritable: false),
            Account.Meta(publicKey: accounts.rent ?? PublicKey.sysvarRent, isSigner: false, isWritable: false)
        ]

        var data = [Index.create]

        var writtenMetadata = Data()
        try! arguments.data.serialize(to: &writtenMetadata)
        data.append(contentsOf: writtenMetadata.bytes)
        data.append(contentsOf: arguments.isMutable.bytes)

        var collectionDetailsBytes = [UInt8(0)]
        if let collectionDetails = arguments.collectionDetails {
            var writtenCollectionDetails = Data()
            try! collectionDetails.serialize(to: &writtenCollectionDetails)
            collectionDetailsBytes = writtenCollectionDetails.bytes
        }
        data.append(contentsOf: collectionDetailsBytes)

        return TransactionInstruction(
            keys: keys,
            programId: programId,
            data: data
        )
    }
}
