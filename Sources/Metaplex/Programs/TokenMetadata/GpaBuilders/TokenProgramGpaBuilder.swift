//
//  TokenProgramGpaBuilder.swift
//  
//
//  Created by Arturo Jamaica on 4/21/22.
//

import Foundation
import Solana

let MINT_SIZE: UInt64 = 82
let ACCOUNT_SIZE: UInt64 = 165

class TokenProgramGpaBuilder: GpaBuilder {
    var connection: Connection
    var programId: PublicKey
    var config: GetProgramAccountsConfig = GetProgramAccountsConfig(encoding: "base64")!
    
    required init(connection: Connection, programId: PublicKey) {
        self.connection = connection
        self.programId = programId
    }
    
    func mintAccounts() -> MintGpaBuilder {
        var g =  GpaBuilderFactory.from(instace: MintGpaBuilder.self, builder: self)
        return g.whereSize(dataSize: MINT_SIZE)
    }
    
    func tokenAccounts() -> TokenGpaBuilder {
        var g =  GpaBuilderFactory.from(instace: TokenGpaBuilder.self, builder: self)
        return g.whereSize(dataSize: ACCOUNT_SIZE)
    }
}
