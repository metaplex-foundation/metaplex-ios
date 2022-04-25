//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 4/21/22.
//

import Foundation
import Solana

class TokenGpaBuilder: TokenProgramGpaBuilder {
    func selectMint() -> TokenGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.slice(offset: 0, length: 32)
    }

    func whereMint(mint: PublicKey) -> TokenGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 0, publicKey: mint)
    }

    func selectOwner() -> TokenGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.slice(offset: 32, length: 32)
    }

    func whereOwner(owner: PublicKey) -> TokenGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 32, publicKey: owner)
    }

    func selectAmount() -> TokenGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.slice(offset: 64, length: 8)
    }

    func whereAmount(amount: UInt64) -> TokenGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 64, int: amount)
    }

    func whereDoesntHaveDelegate() -> TokenGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 72, byte: 0)
    }

    func whereHasDelegate() -> TokenGpaBuilder {
        var mutableGpaBulder = self
        return mutableGpaBulder.where(offset: 72, byte: 1)
    }

    func whereDelegate(delegate: PublicKey) -> TokenGpaBuilder {
        var mutableGpaBulder = self
        mutableGpaBulder = mutableGpaBulder.whereHasDelegate()
        return mutableGpaBulder.where(offset: 76, publicKey: delegate)
    }
}
