//
//  TokenMetadataGpaBuilder.swift
//  
//
//  Created by Arturo Jamaica on 4/20/22.
//

import Foundation

class TokenMetadataGpaBuilder: GpaBuilder {
    func whereKey(key: MetadataKey) -> MetadataV1GpaBuilder {
        return self.where(offset: 0, byte: UInt8(key.value())) as! MetadataV1GpaBuilder
    }
    
    func metadataV1Accounts() -> MetadataV1GpaBuilder {
        let metadata: MetadataV1GpaBuilder = MetadataV1GpaBuilder.from(builder: self)
        return metadata.whereKey(key: MetadataKey.MetadataV1)
    }
    
    func masterEditionV1Accounts() -> GpaBuilder {
        return self.whereKey(key: MetadataKey.MasterEditionV1);
    }
    
    func masterEditionV2Accounts() -> GpaBuilder {
        return self.whereKey(key: MetadataKey.MasterEditionV1)
    }
}
