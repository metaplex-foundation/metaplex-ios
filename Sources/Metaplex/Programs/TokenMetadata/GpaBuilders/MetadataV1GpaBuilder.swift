//
//  MetadataV1GpaBuilder.swift
//  
//
//  Created by Arturo Jamaica on 4/20/22.
//

import Foundation
import Solana

let DATA_START = 1 + 32 + 32
let NAME_START = DATA_START + 4
let SYMBOL_START = NAME_START + MAX_NAME_LENGTH + 4
let URI_START = SYMBOL_START + MAX_SYMBOL_LENGTH + 4
let CREATORS_START = URI_START + MAX_URI_LENGTH + 2 + 1 + 4

class MetadataV1GpaBuilder: TokenMetadataGpaBuilder {
    func selectUpdatedAuthority() -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.slice(offset: 1, length: 3)
    }

    func whereUpdateAuthority(updateAuthority: PublicKey) -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 1, publicKey: updateAuthority)
    }

    func selectMint() -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.slice(offset: 33, length: 32)
    }

    func whereMint(mint: PublicKey) -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 33, publicKey: mint)
    }

    func selectName() -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.slice(offset: NAME_START, length: MAX_NAME_LENGTH)
    }

    func whereName(name: String) -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: UInt(NAME_START), string: name)
    }

    func selectSymbol() -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.slice(offset: SYMBOL_START, length: MAX_SYMBOL_LENGTH)
    }

    func whereSymbol(symbol: String) -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: UInt(SYMBOL_START), string: symbol)
    }

    func selectUri() -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.slice(offset: URI_START, length: MAX_URI_LENGTH)
    }

    func whereUri(uri: String) -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: UInt(URI_START), string: uri)
    }

    func selectCreator(nth: Int) -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.slice(
            offset: CREATORS_START + (nth - 1) * MAX_CREATOR_LEN,
            length: CREATORS_START + nth * MAX_CREATOR_LEN
        )
    }

    func whereCreator(nth: Int, creator: PublicKey) -> MetadataV1GpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: UInt(CREATORS_START + (nth - 1) * MAX_CREATOR_LEN), publicKey: creator)
    }

    func selectFirstCreator() -> MetadataV1GpaBuilder {
        return self.selectCreator(nth: 1)
    }

    func whereFirstCreator(firstCreator: PublicKey) -> MetadataV1GpaBuilder {
        return self.whereCreator(nth: 1, creator: firstCreator)
    }
}
