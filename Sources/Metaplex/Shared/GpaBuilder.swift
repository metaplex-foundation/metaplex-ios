//
//  GpaBuilder.swift
//  
//
//  Created by Arturo Jamaica on 4/18/22.
//

import Beet
import Foundation
import Solana

struct AccountPublicKey: BufferLayout {
    let publicKey: PublicKey

    static var BUFFER_LENGTH: UInt64 = 32
    init(from reader: inout BinaryReader) throws {
        self.publicKey = try .init(from: &reader)
    }

    func serialize(to writer: inout Data) throws {
        try publicKey.serialize(to: &writer)
    }
}

struct RequestMemCmpFilter: Encodable {
    let offset: UInt
    let bytes: String
}

struct RequestDataSizeFilter: Encodable {
    let dataSize: UInt64

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(dataSize)
    }
}

struct AccountInfoWithPublicKey<B: BufferLayout> {
    public let pubkey: PublicKey
    public let account: BufferInfo<B>
}

struct AccountInfoWithPureData {
    public let pubKey: PublicKey
    public let account: BufferInfoPureData
}

typealias GetProgramAccountsConfig = RequestConfiguration

extension GetProgramAccountsConfig {
    func merge(_ other: GetProgramAccountsConfig) -> GetProgramAccountsConfig {
        return GetProgramAccountsConfig(
            commitment: other.commitment ?? self.commitment,
            encoding: other.encoding ?? self.encoding,
            dataSlice: other.dataSlice ?? self.dataSlice,
            filters: other.filters ?? self.filters,
            limit: other.limit ?? self.limit,
            before: other.before ?? self.before,
            until: other.until ?? self.until
        ) ?? self
    }

    func copyAndReplace(commitment: Commitment? = nil, encoding: String? = nil, dataSlice: DataSlice? = nil, filters: [[String: EncodableWrapper]]? = nil, limit: Int? = nil, before: String? = nil, until: String? = nil) -> GetProgramAccountsConfig {
        return GetProgramAccountsConfig(
            commitment: commitment ?? self.commitment,
            encoding: encoding ?? self.encoding,
            dataSlice: dataSlice ?? self.dataSlice,
            filters: filters ?? self.filters,
            limit: limit ?? self.limit,
            before: before ?? self.before,
            until: until ?? self.until
        ) ?? self
    }
}

class GpaBuilderFactory {
    static func from<T: GpaBuilder>(instace: T.Type, builder: GpaBuilder) -> T {
        var newBuilder = T(connection: builder.connection, programId: builder.programId)
        return newBuilder.mergeConfig(config: builder.config)
    }
}

protocol GpaBuilder {
    var connection: Connection { get }
    var programId: PublicKey { get }
    var config: GetProgramAccountsConfig { get set }

    init(connection: Connection, programId: PublicKey)
}
extension GpaBuilder {
    mutating func mergeConfig<T: GpaBuilder>(config: GetProgramAccountsConfig) -> T {
        self.config = self.config.merge(config)
        return self as! T
    }

    mutating func slice<T: GpaBuilder>(offset: Int, length: Int) -> T {
        self.config = self.config.copyAndReplace(dataSlice: DataSlice(offset: offset, length: length))
        return self as! T
    }

    mutating func withoutData<T: GpaBuilder>() -> T {
        return self.slice(offset: 0, length: 0)
    }

    mutating func addFilter<T: GpaBuilder>(filter: [String: EncodableWrapper]) -> T {
        var filters = (self.config.filters ?? [])
        filters.append(filter)
        self.config = self.config.copyAndReplace(filters: filters)
        return self as! T
    }

    mutating func `where`<T: GpaBuilder>(offset: UInt, publicKey: PublicKey) -> T {
        let memcmpParams = RequestMemCmpFilter(offset: offset, bytes: publicKey.base58EncodedString)
        let memcmpEncoded = EncodableWrapper(wrapped: memcmpParams)
        return self.addFilter(filter: ["memcmp": memcmpEncoded])
    }

    mutating func `where`<T: GpaBuilder>(offset: UInt, bytes: [UInt8]) -> T {
        let memcmpParams = RequestMemCmpFilter(offset: offset, bytes: Base58.encode(bytes))
        let memcmpEncoded = EncodableWrapper(wrapped: memcmpParams)
        return self.addFilter(filter: ["memcmp": memcmpEncoded])
    }

    mutating func `where`<T: GpaBuilder>(offset: UInt, string: String) -> T {
        let memcmpParams: RequestMemCmpFilter = RequestMemCmpFilter(offset: offset, bytes: string)
        let memcmpEncoded = EncodableWrapper(wrapped: memcmpParams)
        return self.addFilter(filter: ["memcmp": memcmpEncoded])
    }

    mutating func `where`<T: GpaBuilder>(offset: UInt, int: UInt64) -> T {
        let memcmpParams = RequestMemCmpFilter(offset: offset, bytes: Base58.encode(int.bytes))
        let memcmpEncoded = EncodableWrapper(wrapped: memcmpParams)
        return self.addFilter(filter: ["memcmp": memcmpEncoded])
    }

    mutating func `where`<T: GpaBuilder>(offset: UInt, byte: UInt8) -> T {
        let memcmpParams = RequestMemCmpFilter(offset: offset, bytes: Base58.encode([byte]))
        let memcmpEncoded = EncodableWrapper(wrapped: memcmpParams)
        return self.addFilter(filter: ["memcmp": memcmpEncoded])
    }

    mutating func whereSize<T: GpaBuilder>(dataSize: UInt64) -> T {
        let requestDataSize = RequestDataSizeFilter(dataSize: dataSize)
        let requestEncoded = EncodableWrapper(wrapped: requestDataSize)
        return self.addFilter(filter: ["dataSize": requestEncoded])
    }

    func get<B: BufferLayout>() -> OperationResult<[AccountInfoWithPublicKey<B>], Error> {
        return OperationResult<[ProgramAccount<B>], Error> { cb in
            self.connection.getProgramAccounts(publicKey: self.programId, decodedTo: B.self, config: self.config) { result in
                cb(result)
            }
        }.map { programAccount in
            var infoAccounts: [AccountInfoWithPublicKey<B>] = []
            programAccount.forEach { programAccount in
                let infoAccount = AccountInfoWithPublicKey<B>(pubkey: PublicKey(string: programAccount.pubkey)!, account: programAccount.account)
                infoAccounts.append(infoAccount)
            }
            return infoAccounts
        }
    }

    func getPureData() -> OperationResult<[AccountInfoWithPureData], Error> {
        return OperationResult<[ProgramAccountPureData], Error> { cb in
            self.connection.getProgramAccounts(publicKey: self.programId, config: self.config) { result in
                cb(result)
            }
        }.map { programAccount in
            var infoAccounts: [AccountInfoWithPureData] = []
            programAccount.forEach { programAccount in
                let infoAccount = AccountInfoWithPureData(pubKey: PublicKey(string: programAccount.publicKey)!, account: programAccount.account)
                infoAccounts.append(infoAccount)
            }
            return infoAccounts
        }
    }

    func getAndMap<B: BufferLayout, T>(_ callback: @escaping (_ account: [AccountInfoWithPublicKey<B>]) -> T) -> OperationResult<T, Error> {
        return self.get().map(callback)
    }

    func getAndMap<T>(_ callback: @escaping (_ account: [AccountInfoWithPureData]) -> T) -> OperationResult<T, Error> {
        return self.getPureData().map(callback)
    }

    func getPublicKeys() -> OperationResult<[PublicKey], Error> {
        return self.getAndMap { (account: [AccountInfoWithPublicKey<AccountPublicKey>]) in
            account.map { $0.pubkey }
        }
    }

    func getDataAsPublicKeys () -> OperationResult<[PublicKey], Error> {
        return self.getAndMap { (account: [AccountInfoWithPublicKey<AccountPublicKey>]) in
            account.map { $0.account.data.value!.publicKey }
        }
    }
}

extension FixedWidthInteger where Self: UnsignedInteger {

    var bytes: [UInt8] {
        var _endian = littleEndian
        let bytePtr = withUnsafePointer(to: &_endian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Self>.size) {
                UnsafeBufferPointer(start: $0, count: MemoryLayout<Self>.size)
            }
        }
        return [UInt8](bytePtr)
    }

}
