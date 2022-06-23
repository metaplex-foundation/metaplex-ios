//
//  NFT.swift
//  
//
//  Created by Arturo Jamaica on 4/11/22.
//

import Foundation
import Solana

public class NFT {
    public let metadataAccount: MetadataAccount
    public let masterEditionAccount: MasterEditionAccount?
    
    /** Data from the Metadata account. */
    public let updateAuthority: PublicKey
    public let mint: PublicKey
    public let name: String
    public let symbol: String
    public let uri: String
    public let sellerFeeBasisPoints: UInt16
    public let creators: [MetaplexCreator]
    public let primarySaleHappened: Bool
    public let isMutable: Bool
    public let editionNonce: UInt8?
    public let tokenStandard: MetaplexTokenStandard?
    public let collection: MetaplexCollection?

    public init(metadataAccount: MetadataAccount, masterEditionAccount: MasterEditionAccount?) {
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
        self.tokenStandard = metadataAccount.tokenStandard
        self.collection = metadataAccount.collection
    }
    
    public func metadata(metaplex: Metaplex, onComplete: @escaping (Result<JsonMetadata, Error>) -> Void) {
        JsonMetadataTask(metaplex: metaplex, nft: self).use { result in
            switch result {
            case .success(let metadata):
                onComplete(.success(metadata))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}

extension NFT: Equatable {
    public static func == (lhs: NFT, rhs: NFT) -> Bool {
        return lhs.mint.base58EncodedString == rhs.mint.base58EncodedString
    }
}
