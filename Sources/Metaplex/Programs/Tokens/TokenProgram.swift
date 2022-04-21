//
//  TokenProgram.swift
//  
//
//  Created by Arturo Jamaica on 4/21/22.
//

import Foundation
import Solana

class TokenProgram {
    let publicKey = PublicKey.tokenProgramId
    
    func accounts(connection: Connection) -> TokenProgramGpaBuilder {
        return TokenProgramGpaBuilder(connection: connection, programId: publicKey)
    }
    
    func mintAccounts(connection: Connection) -> MintGpaBuilder {
        return self.accounts(connection: connection).mintAccounts()
    }
    
    func tokenAccounts(connection: Connection) -> TokenGpaBuilder {
        return self.accounts(connection: connection).tokenAccounts()
    }
}
