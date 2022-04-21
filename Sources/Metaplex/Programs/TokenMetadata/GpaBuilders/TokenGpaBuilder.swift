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
        return self.slice(offset: 0, length: 32)
    }
    
    func whereMint(mint: PublicKey) -> TokenGpaBuilder {
        return self.where(offset: 0, publicKey: mint)
    }
    
    func selectOwner() -> TokenGpaBuilder {
        return self.slice(offset: 32, length: 32)
    }
    
    func whereOwner(owner: PublicKey) -> TokenGpaBuilder {
        return self.where(offset: 32, publicKey: owner)
    }
    
    func selectAmount() -> TokenGpaBuilder {
        return self.slice(offset: 64, length: 8)
    }
    
    func whereAmount(amount: Int) -> TokenGpaBuilder {
        return self.where(offset: 64, int: amount)
    }
    
    func whereDoesntHaveDelegate() -> TokenGpaBuilder {
        return self.where(offset:72, byte: 0)
    }
    
    func whereHasDelegate() -> TokenGpaBuilder {
        return self.where(offset: 72, byte: 1)
    }
    
    func whereDelegate(delegate: PublicKey) -> TokenGpaBuilder {
        return self.whereHasDelegate().where(offset: 76, publicKey: delegate)
    }
}
