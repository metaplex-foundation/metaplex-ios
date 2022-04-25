//
//  MintGpaBuilder.swift
//  
//
//  Created by Arturo Jamaica on 4/21/22.
//

import Foundation
import Solana

class MintGpaBuilder: TokenProgramGpaBuilder {
    func whereDoesntHaveMintAuthority() -> MintGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 0, byte: 0)
    }

    func whereHasMintAuthority() -> MintGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 0, byte: 1)
    }

    func whereMintAuthority(mintAuthority: PublicKey) -> MintGpaBuilder {
        var mutableGpaBulder = self
        mutableGpaBulder = mutableGpaBulder.whereHasMintAuthority()
        return mutableGpaBulder.where(offset: 4, publicKey: mintAuthority)
    }

    func whereSupply(supply: UInt64) -> MintGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 36, int: supply)
    }
}
