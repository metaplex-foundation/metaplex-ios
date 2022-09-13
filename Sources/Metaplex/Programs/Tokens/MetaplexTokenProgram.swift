//
//  TokenProgram.swift
//  
//
//  Created by Arturo Jamaica on 4/21/22.
//

import Foundation
import Solana

public class MetaplexTokenProgram {
    static let publicKey = PublicKey.tokenProgramId

    static func accounts(connection: Connection) -> TokenProgramGpaBuilder {
        return TokenProgramGpaBuilder(connection: connection, programId: publicKey)
    }

    static func mintAccounts(connection: Connection) -> MintGpaBuilder {
        return self.accounts(connection: connection).mintAccounts()
    }

    static func tokenAccounts(connection: Connection) -> TokenGpaBuilder {
        return self.accounts(connection: connection).tokenAccounts()
    }
}
