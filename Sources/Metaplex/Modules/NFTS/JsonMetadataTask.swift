//
//  File.swift
//  
//
//  Created by Arturo Jamaica on 5/18/22.
//

import Foundation


struct JsonMetadataTask {
    let metaplex: Metaplex
    let nft: NFT

    func use(onComplete: @escaping (Result<JsonMetadata, StorageDriverError>) -> Void) {
        guard let url = URL(string: nft.uri) else {
            onComplete(.failure(.invalidURL))
            return
        }
        metaplex.storage().download(url: url) { result in
            switch result {
            case .success(let response):
                do {
                    let jsonMetaData = try JSONDecoder().decode(JsonMetadata.self, from: response.data)
                    onComplete(.success(jsonMetaData))
                } catch let error {
                    onComplete(.failure(.canNotParse(error: error)))
                }
            case .failure(let error):
                onComplete(.failure(.networkingError(error: error)))
            }
        }
    }
}
