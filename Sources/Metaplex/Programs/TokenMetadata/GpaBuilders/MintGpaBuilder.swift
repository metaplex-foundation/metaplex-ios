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
        return self.where(offset: 0, byte: 0)
    }
    
    func whereHasMintAuthority() -> MintGpaBuilder {
        return self.where(offset:0, byte: 1);
    }
    
    func whereMintAuthority(mintAuthority: PublicKey) -> MintGpaBuilder {
        return self.whereHasMintAuthority().where(offset: 4, publicKey: mintAuthority);
    }
    
    func whereSupply(supply: Int) -> MintGpaBuilder {
        return self.where(offset: 36, int: supply);
    }
}
