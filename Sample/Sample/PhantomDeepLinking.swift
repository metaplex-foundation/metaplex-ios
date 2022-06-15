//
//  Phantom.swift
//  Sample
//
//  Created by Arturo Jamaica on 6/14/22.
//

import Foundation
import UIKit
import Solana
import TweetNacl

private let PHANTOM_URL = "phantom.app"
typealias Cluster = Network

enum PhantomError: Error {
    case couldNotDecryptPayload
    case invalidParameters
    case hostNotSupported(String)
    case schemeNotFound(String)
    case errorResponse(PhantomErrorResponse)
}
struct DappKeyPair {
    let publicKey: Data
    let secretKey: Data
    var sharedSecretDapp: Data?
}
struct PhantomRequest {
    let dapp_encryption_public_key: String?
    let nonce: String
    let redirect_link: String
    let payload: String
}

enum PhantomResponse {
    case onConnect(response: PhantomConnectResponseData)
    case onDisconnect
    case onSignAndSendTransaction(response: PhantomSignAndSendTransactionResponse)
    case onSignAllTransactions
    case onSignTransaction
    case onSignMessage
}

enum PhantomAction: String {
    case connect
    case disconnect
    case signAndSendTransaction
    case signAllTransactions
    case signTransaction
    case signMessage
    
    var host: String {
        switch self {
        case .connect:
            return "onConnect"
        case .disconnect:
            return "onDisconnect"
        case .signAndSendTransaction:
            return "onSignAndSendTransaction"
        case .signAllTransactions:
            return "onSignAllTransactions"
        case .signTransaction:
            return "onSignTransaction"
        case .signMessage:
            return "signMessage"
        }
    }
}

class PhantomDeepLink {
    
    private let urlSchema = "metaplex"
    private let appUrl = "https://\(PHANTOM_URL)"
    private let cluster: Cluster
    
    private let parser: PhantomDeepLinkParser
    private let urlConstructor: PhantomDeepLinkGenerator
    
    private let dappKeyPair: DappKeyPair
    
    var onConnect: ((PhantomConnectResponseData) -> Void)? = nil
    
    init(keyPair: (publicKey: Data, secretKey: Data), cluster: Cluster?) {
        self.dappKeyPair = DappKeyPair(publicKey: keyPair.publicKey, secretKey: keyPair.secretKey)
        self.cluster = cluster ?? .mainnetBeta
        self.parser = PhantomDeepLinkParser(urlSchema: urlSchema, dappKeyPair: dappKeyPair)
        self.urlConstructor = PhantomDeepLinkGenerator(urlSchema: urlSchema, dappKeyPair: dappKeyPair)
    }
    
    func connect() {
        var components = URLComponents()
        components.scheme = "https"
        components.host = PHANTOM_URL
        components.path = "/ul/v1/\(PhantomAction.connect)"
        
        components.queryItems = [
            URLQueryItem(name: "dapp_encryption_public_key", value: Base58.encode(dappKeyPair.publicKey.bytes)),
            URLQueryItem(name: "redirect_link", value: urlConstructor.redirectLinkString(host: PhantomAction.connect)),
            URLQueryItem(name: "cluster", value: cluster.cluster),
            URLQueryItem(name: "app_url", value: appUrl)
        ]
        launchURL(url: components.url!)
    }
    
    func handleURL(_ url: URL) -> Result<PhantomResponse, PhantomError> {
        self.parser.handleURL(url).also { 
            switch $0 {
            case .onConnect(response: let response):
                self.onConnect?(response)
            default:
                break
            }
        }
    }
    
    private func launchURL(url: URL){
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

class PhantomDeepLinkGenerator {
    private let urlSchema: String
    
    private let dappKeyPair: DappKeyPair
    private var sharedSecretDapp: Data?
    
    init(urlSchema: String, dappKeyPair: DappKeyPair){
        self.urlSchema = urlSchema
        self.dappKeyPair = dappKeyPair
    }
    
    func redirectLinkString(host: PhantomAction) -> String {
        return "\(urlSchema)://\(host.host)"
    }
    
    private func encryptPayload(payload: Data, nonce: String) -> Data {
        return try! NaclSecretBox.secretBox(
            message: payload,
            nonce: Data(Base58.decode(nonce)),
            key: self.sharedSecretDapp!)
    }
}

class PhantomDeepLinkParser {
    
    private let urlSchema: String
    
    private var dappKeyPair: DappKeyPair
    
    
    init(urlSchema: String, dappKeyPair: DappKeyPair){
        self.urlSchema = urlSchema
        self.dappKeyPair = dappKeyPair
    }
    
    private func setSharedSecretDapp(phantom_encryption_public_key: String) {
        self.dappKeyPair.sharedSecretDapp = try! NaclBox.before(
            publicKey: Data(Base58.decode(phantom_encryption_public_key)),
            secretKey: dappKeyPair.secretKey
        )
    }
    
    private func decryptPayload(data: String, nonce: String, publicKey: String) -> Data {
        return try! NaclSecretBox.open(
            box: Data(Base58.decode(data)),
            nonce: Data(Base58.decode(nonce)),
            key: self.dappKeyPair.sharedSecretDapp!
        )
    }
    
    func handleURL(_ url: URL) -> Result<PhantomResponse, PhantomError> {
        if let scheme = url.scheme, scheme != urlSchema { return .failure(.schemeNotFound(scheme)) }
        let section = url.host
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if let errorCode = components?.queryItems?.first(where: { $0.name == "errorCode" })?.value,
           let errorMessage = components?.queryItems?.first(where: { $0.name == "errorMessage" })?.value {
            return .failure(.errorResponse(.init(errorCode: errorCode, errorMessage: errorMessage)))
        }
        
        switch section {
        case PhantomAction.connect.host:
            guard let phantom_encryption_public_key = components?.queryItems?.first(where: { $0.name == "phantom_encryption_public_key" })?.value,
                  let nonce = components?.queryItems?.first(where: { $0.name == "nonce" })?.value,
                  let data = components?.queryItems?.first(where: { $0.name == "data" })?.value else {
                return .failure(.invalidParameters)
            }
            setSharedSecretDapp(phantom_encryption_public_key: phantom_encryption_public_key)
            let jsonData = decryptPayload(data: data, nonce: nonce, publicKey: phantom_encryption_public_key)
            let connectResponseData = try! JSONDecoder().decode(PhantomConnectResponseData.self, from: jsonData)
            
            return .success(.onConnect(response: PhantomConnectResponseData(public_key: connectResponseData.public_key, session: connectResponseData.session)))
        default:
            return .failure(.hostNotSupported("\(section ?? "")"))
        }
    }
}

struct PhantomErrorResponse {
    let errorCode: String
    let errorMessage: String
}

struct PhantomConnectResponseData: Decodable {
    let public_key: String
    let session: String
}

struct PhantomSignAndSendTransactionResponse {
    let signature: String
}

struct PhantomSignTransactionResponse {
    let transactions: [String]
}

struct PhantomSignMessageResponse {
    let signature: String
}
