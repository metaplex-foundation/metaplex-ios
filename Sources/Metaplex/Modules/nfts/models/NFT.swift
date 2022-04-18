//
//  NFT.swift
//  
//
//  Created by Arturo Jamaica on 4/11/22.
//

import Foundation
import Solana

struct NFT {
    let metadataAccount: MetadataAccount
    let masterEditionAccount: MasterEditionAccount
    
    /** Data from the Metadata account. */
    let updateAuthority: PublicKey
    let mint: PublicKey
    let name: String
    let symbol: String
    let uri: String
    let sellerFeeBasisPoints: UInt16
    let creators: [MetaplexCreator]
    let primarySaleHappened: Bool
    let isMutable: Bool
    let editionNonce: UInt8?
        
    init(metadataAccount: MetadataAccount, masterEditionAccount: MasterEditionAccount){
        self.metadataAccount = metadataAccount
        self.masterEditionAccount = masterEditionAccount
        
        self.updateAuthority = metadataAccount.updateAuthority
        self.mint = metadataAccount.mint
        self.name = metadataAccount.data.name
        self.symbol = metadataAccount.data.symbol
        self.uri = metadataAccount.data.uri
        self.sellerFeeBasisPoints = metadataAccount.data.sellerFeeBasisPoints
        self.creators = metadataAccount.data.creators
        self.primarySaleHappened = metadataAccount.primarySaleHappened
        self.isMutable = metadataAccount.isMutable
        self.editionNonce = metadataAccount.editionNonce
    }
}

extension NFT: Equatable {
    static func == (lhs: NFT, rhs: NFT) -> Bool {
        return lhs.mint.base58EncodedString == rhs.mint.base58EncodedString
    }
}
