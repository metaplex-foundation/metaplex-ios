//
//  TokenMetadataProgram.swift
//  
//
//  Created by Arturo Jamaica on 4/20/22.
//

import Foundation
import Solana

public class TokenMetadataProgram {
    static let publicKey =
    PublicKey(string: "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s")!

    static func accounts(connection: Connection) -> TokenMetadataGpaBuilder {
        return TokenMetadataGpaBuilder(connection: connection, programId: TokenMetadataProgram.publicKey)
    }

    static func metadataV1Accounts(connection: Connection) -> MetadataV1GpaBuilder {
        return self.accounts(connection: connection).metadataV1Accounts()
    }
}
