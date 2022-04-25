//
//  TokenMetadataGpaBuilder.swift
//  
//
//  Created by Arturo Jamaica on 4/20/22.
//

import Foundation
import Solana

class TokenMetadataGpaBuilder: GpaBuilder {
    var connection: Connection
    var programId: PublicKey
    var config: GetProgramAccountsConfig = GetProgramAccountsConfig(encoding: "base64")!

    required init(connection: Connection, programId: PublicKey) {
        self.connection = connection
        self.programId = programId
    }

    func whereKey(key: MetadataKey) -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 0, byte: UInt8(key.value()))
    }

    func metadataV1Accounts() -> MetadataV1GpaBuilder {
        let metadata = GpaBuilderFactory.from(instace: MetadataV1GpaBuilder.self, builder: self)
        return metadata.whereKey(key: MetadataKey.MetadataV1)
    }

    func masterEditionV1Accounts() -> GpaBuilder {
        return self.whereKey(key: MetadataKey.MasterEditionV1)
    }

    func masterEditionV2Accounts() -> GpaBuilder {
        return self.whereKey(key: MetadataKey.MasterEditionV1)
    }
}
