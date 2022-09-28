//
//  RawAccount.swift
//  
//
//  Created by Michael J. Huber Jr. on 9/28/22.
//

import Beet
import Foundation
import Solana

public struct RawAccount: BufferLayout {
    public static let BUFFER_LENGTH: UInt64 = 165

    public let mint: PublicKey
    public let owner: PublicKey
    public let amount: UInt64
    public let delegateOption: Bool
    public let delegate: PublicKey
    public let state: UInt8
    public let isNativeOption: Bool
    public let isNative: UInt64
    public let delegatedAmount: UInt64
    public let closeAuthorityOption: Bool
    public let closeAuthority: PublicKey
}

extension RawAccount: BorshCodable {
    public func serialize(to writer: inout Data) throws {

    }

    public init(from reader: inout BinaryReader) throws {
        self.mint = try .init(from: &reader)
        self.owner = try .init(from: &reader)
        self.amount = try .init(from: &reader)
        self.delegateOption = try .init(from: &reader)
        self.delegate = try .init(from: &reader)
        self.state = try .init(from: &reader)
        self.isNativeOption = try .init(from: &reader)
        self.isNative = try .init(from: &reader)
        self.delegatedAmount = try .init(from: &reader)
        self.closeAuthorityOption = try .init(from: &reader)
        self.closeAuthority = try .init(from: &reader)
    }
}
