//
//  TokenProgramGpaBuilder.swift
//  
//
//  Created by Arturo Jamaica on 4/21/22.
//

import Foundation

let MINT_SIZE: UInt = 162
let ACCOUNT_SIZE: UInt = 254
class TokenProgramGpaBuilder: GpaBuilder {
    func mintAccounts() -> MintGpaBuilder {
        return MintGpaBuilder.from(builder: self).whereSize(dataSize: MINT_SIZE)
    }
    
    func tokenAccounts() -> TokenGpaBuilder {
        return TokenGpaBuilder.from(builder: self).whereSize(dataSize: ACCOUNT_SIZE);
    }
}
