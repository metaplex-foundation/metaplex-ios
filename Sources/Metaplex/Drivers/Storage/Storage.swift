//
//  Storage.swift
//  
//
//  Created by Arturo Jamaica on 4/8/22.
//

import Foundation

public enum StorageDriverError: Error {
    case invalidURL
    case canNotParse(error: Error)
    case dataAndResponseAndErrorAreNull
    case networkingError(error: Error)
    case jsonParsedError(error: Error)
}

public protocol StorageDriver {
    func download(url: URL, onComplete: @escaping(Result<NetworkingResponse, StorageDriverError>) -> Void)
}

public struct NetworkingResponse {
    public let data: Data
    public let response: URLResponse
}

public class MemoryStorageDriver: StorageDriver {
    public func download(url: URL, onComplete: @escaping (Result<NetworkingResponse, StorageDriverError>) -> Void) {
        onComplete(.success(NetworkingResponse(data: Data(), response: URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil))))
    }
}

public class URLSharedStorageDriver: StorageDriver {
    let urlSession: URLSession
    
    public init(urlSession: URLSession){
        self.urlSession = urlSession
    }
    
    public func download(url: URL, onComplete: @escaping (Result<NetworkingResponse, StorageDriverError>) -> Void) {
        self.asyncDownload(url: url) { data, response, error in
            if let data = data, let response = response {
                onComplete(.success(NetworkingResponse(data: data, response: response)))
            } else if let error = error {
                onComplete(.failure(.networkingError(error: error)))
            } else {
                onComplete(.failure(.dataAndResponseAndErrorAreNull))
            }
        }
    }
    
    private func asyncDownload(url: URL, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()){
        urlSession
            .dataTask(with: url, completionHandler: completion)
            .resume()
    }
}
