import Foundation
import UIKit
import Solana
import TweetNacl
import CryptoKit

private let PHANTOM_URL = "phantom.app"
typealias Cluster = Network

struct DappKeyPair {
    let publicKey: Data
    let secretKey: Data
}

protocol PhantomDecryptor {
    func decryptPayload(
        data: String,
        nonce: String,
        publicKey: String,
        sharedSecretDapp: Data
    ) -> Result<Data, PhantomError>
}

class NaCLDecryptor: PhantomDecryptor {
    func decryptPayload(
        data: String,
        nonce: String,
        publicKey: String,
        sharedSecretDapp: Data
    ) -> Result<Data, PhantomError> {
        
        do {
            let decryptedData = try NaclSecretBox.open(
                box: Data(Base58.decode(data)),
                nonce: Data(Base58.decode(nonce)),
                key: sharedSecretDapp
            )
            return .success(decryptedData)
        } catch let error {
            return .failure(.couldNotDecrypt(error))
        }
    }
}

protocol PhantomEncryptor {
    func encryptPayload(
        payload: Data,
        nonce: String,
        sharedSecretDapp: Data
    ) -> Result<Data, PhantomError>
}

class NaCLEncryptor: PhantomEncryptor {
    func encryptPayload(
        payload: Data,
        nonce: String,
        sharedSecretDapp: Data
    ) -> Result<Data, PhantomError> {
        do {
            let encryptedData = try NaclSecretBox.secretBox(
                message: payload,
                nonce: Data(Base58.decode(nonce)),
                key: sharedSecretDapp
            )
            return .success(encryptedData)
        } catch let error {
            return .failure(PhantomError.couldNotEncrypt(error))
        }
    }
}

struct PhantomErrorResponse {
    let errorCode: String
    let errorMessage: String
}

enum PhantomError: Error {
    case invalidParameters
    case hostNotSupported(String)
    case schemeNotFound(String)
    case errorResponse(PhantomErrorResponse)
    case couldNotDecrypt(Error)
    case couldNotEncrypt(Error)
    case couldNotDecodeResponse(Error)
    case couldNotEncodeRequest(Error)
    case couldNotGenerateSharedSecret(Error)
}

struct DappSession {
    var sharedSecretDapp: Data?
    var session: String?
    var phantomEncryptionPublickey: String?
}

struct PhantomConnectResponseData: Decodable {
    let public_key: String
    let session: String
    
    static func decode(data: Data) -> Result<PhantomConnectResponseData, PhantomError>{
        do{
            let phantomConnectResponseData = try JSONDecoder().decode(
                PhantomConnectResponseData.self,
                from: data
            )
            return .success(phantomConnectResponseData)
        } catch let error {
            return .failure(.couldNotDecodeResponse(error))
        }
    }
}

struct PhantomSignAndSendTransactionResponseData: Decodable {
    let signature: String
    
    static func decode(data: Data) -> Result<PhantomSignAndSendTransactionResponseData, PhantomError>{
        do{
            let phantomSignAndSendTransactionResponseData = try JSONDecoder().decode(
                PhantomSignAndSendTransactionResponseData.self,
                from: data
            )
            return .success(phantomSignAndSendTransactionResponseData)
        } catch let error {
            return .failure(.couldNotDecodeResponse(error))
        }
    }
}

struct PhantomSignTransactionResponseData: Decodable {
    let transactions: String
    
    static func decode(data: Data) -> Result<PhantomSignTransactionResponseData, PhantomError>{
        do{
            let phantomSignTransactionResponseData = try JSONDecoder().decode(
                PhantomSignTransactionResponseData.self,
                from: data
            )
            return .success(phantomSignTransactionResponseData)
        } catch let error {
            return .failure(.couldNotDecodeResponse(error))
        }
    }
}

struct PhantomSignAllTransactionsResponseData: Decodable {
    let transactions: [String]
    
    static func decode(data: Data) -> Result<PhantomSignAllTransactionsResponseData, PhantomError>{
        do{
            let phantomSignAllTransactionsResponseData = try JSONDecoder().decode(
                PhantomSignAllTransactionsResponseData.self,
                from: data
            )
            return .success(phantomSignAllTransactionsResponseData)
        } catch let error {
            return .failure(.couldNotDecodeResponse(error))
        }
    }
}

struct PhantomSignMessageResponseData: Decodable {
    let signature: String
    
    static func decode(data: Data) -> Result<PhantomSignMessageResponseData, PhantomError>{
        do{
            let phantomSignMessageResponseData = try JSONDecoder().decode(
                PhantomSignMessageResponseData.self,
                from: data
            )
            return .success(phantomSignMessageResponseData)
        } catch let error {
            return .failure(.couldNotDecodeResponse(error))
        }
    }
}

enum DisplayType: String, Encodable {
    case hex, utf8
}

struct DisconnectPayload: Encodable {
    let session: String
    
    func encode() -> Result<String, PhantomError> {
        do {
            let enodedData = try JSONEncoder().encode(self)
            return .success(String(data: enodedData, encoding: .utf8)!)
        } catch let error {
            return .failure(.couldNotEncrypt(error))
        }
    }
}

struct SignTransactionPayload: Encodable {
    let session: String
    let transaction: String
    
    func encode() -> Result<String, PhantomError> {
        do {
            let enodedData = try JSONEncoder().encode(self)
            return .success(String(data: enodedData, encoding: .utf8)!)
        } catch let error {
            return .failure(.couldNotEncrypt(error))
        }
    }
}

struct SignAllTransactionsPayload: Encodable {
    let session: String
    let transactions: [String]
    
    func encode() -> Result<String, PhantomError> {
        do {
            let enodedData = try JSONEncoder().encode(self)
            return .success(String(data: enodedData, encoding: .utf8)!)
        } catch let error {
            return .failure(.couldNotEncrypt(error))
        }
    }
}

enum PhantomResponse {
    case onConnect(response: PhantomConnectResponseData, sharedSecretDapp: Data, phantomEncryptionPublickey: String)
    case onDisconnect
    case onSignAndSendTransaction(response: PhantomSignAndSendTransactionResponseData)
    case onSignAllTransactions(response: PhantomSignAllTransactionsResponseData)
    case onSignTransaction(response: PhantomSignTransactionResponseData)
    case onSignMessage(response: PhantomSignMessageResponseData)
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
    
    private let urlSchema: String
    private let appUrl: String
    private let cluster: Cluster
    
    private var dappKeyPair: DappKeyPair
    private var dappSession: DappSession
    
    private var encryptor: PhantomEncryptor
    private var decryptor: PhantomDecryptor
    
    var onConnect: ((PhantomConnectResponseData) -> Void)? = nil
    var onDisconnect: (() -> Void)? = nil
    var onSignTransaction: ((PhantomSignTransactionResponseData) -> Void)? = nil
    var onSignAndSendTransaction: ((PhantomSignAndSendTransactionResponseData) -> Void)? = nil
    var onSignAllTransactions: ((PhantomSignAllTransactionsResponseData) -> Void)? = nil
    var onSignMessage: ((PhantomSignMessageResponseData) -> Void)? = nil
    
    init(urlSchema: String,
         appUrl: URL,
         keyPair: (publicKey: Data, secretKey: Data),
         cluster: Cluster?,
         dappSession: DappSession?=nil
    ) {
        self.urlSchema = urlSchema
        self.appUrl = appUrl.absoluteString
        self.dappKeyPair = DappKeyPair(publicKey: keyPair.publicKey, secretKey: keyPair.secretKey)
        self.dappSession = dappSession ?? DappSession()
        self.cluster = cluster ?? .mainnetBeta
        self.decryptor = NaCLDecryptor()
        self.encryptor = NaCLEncryptor()
    }
    
    func connect() {
        var queryItems = [String: String]()
        queryItems["dapp_encryption_public_key"] = Base58.encode(dappKeyPair.publicKey.bytes)
        queryItems["redirect_link"] = redirectLinkString(host: PhantomAction.connect)
        queryItems["cluster"] = cluster.cluster
        queryItems["app_url"] = appUrl
        
        if let url = urlConstructor(action: PhantomAction.connect, queryItems: queryItems) {
            launchURL(url: url)
        }
    }
    
    func disconnect() {
        let nonce =  Base58.encode(Array(ChaChaPoly.Nonce.init()))
        DisconnectPayload(session: self.dappSession.session!)
            .encode()
            .flatMap {
                encryptor.encryptPayload(
                    payload: Data($0.bytes),
                    nonce: nonce,
                    sharedSecretDapp: self.dappSession.sharedSecretDapp!
                )
            }.also { [self] in
                var queryItems = [String: String]()
                queryItems["dapp_encryption_public_key"] = Base58.encode(self.dappKeyPair.publicKey.bytes)
                queryItems["redirect_link"] = redirectLinkString(host: PhantomAction.disconnect)
                queryItems["nonce"] = nonce
                queryItems["payload"] = Base58.encode($0.bytes)
                
                if let url = self.urlConstructor(action: PhantomAction.disconnect, queryItems: queryItems) {
                    self.launchURL(url: url)
                }
            }
    }
    
    func signTransaction(transaction: String){
        let nonce =  Base58.encode(Array(ChaChaPoly.Nonce.init()))
        SignTransactionPayload(session: self.dappSession.session!, transaction: transaction)
            .encode()
            .flatMap {
                encryptor.encryptPayload(
                    payload: Data($0.bytes),
                    nonce: nonce,
                    sharedSecretDapp: self.dappSession.sharedSecretDapp!
                )
            }.also { [self] in
                var queryItems = [String: String]()
                queryItems["dapp_encryption_public_key"] = Base58.encode(self.dappKeyPair.publicKey.bytes)
                queryItems["redirect_link"] = redirectLinkString(host: PhantomAction.signTransaction)
                queryItems["nonce"] = nonce
                queryItems["payload"] = Base58.encode($0.bytes)
                
                if let url = self.urlConstructor(action: PhantomAction.signTransaction, queryItems: queryItems) {
                    self.launchURL(url: url)
                }
            }
    }
    
    func handleURL(_ url: URL) -> Result<PhantomResponse, PhantomError> {
        parserHandleURL(url).also { [weak self] in
            switch $0 {
            case .onConnect(response: let response,
                            sharedSecretDapp: let sharedSecretDapp,
                            phantomEncryptionPublickey: let phantomEncryptionPublickey
            ):
                self?.dappSession.session = response.session
                self?.dappSession.phantomEncryptionPublickey  = phantomEncryptionPublickey
                self?.dappSession.sharedSecretDapp = sharedSecretDapp
                self?.onConnect?(response)
            case .onDisconnect:
                self?.onDisconnect?()
            case .onSignTransaction(response: let response):
                self?.onSignTransaction?(response)
            case .onSignAndSendTransaction(response: let response):
                self?.onSignAndSendTransaction?(response)
            case .onSignAllTransactions(response: let response):
                self?.onSignAllTransactions?(response)
            case .onSignMessage(response: let response):
                self?.onSignMessage?(response)
            }
        }
    }
    
    private func urlConstructor(action: PhantomAction, queryItems: [String: String]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = PHANTOM_URL
        components.path = "/ul/v1/\(action)"
        
        components.queryItems = queryItems.map({ (key: String, value: String) in
            URLQueryItem(name: key, value: value)
        })
        return components.url
    }
    
    private func launchURL(url: URL){
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    private func parserHandleURL(_ url: URL) -> Result<PhantomResponse, PhantomError> {
        if let scheme = url.scheme, scheme != urlSchema { return .failure(.schemeNotFound(scheme)) }
        let section = url.host
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if let errorCode = components?.getQueryItem(withKey: "errorCode"),
           let errorMessage = components?.getQueryItem(withKey: "errorMessage" ) {
            return .failure(.errorResponse(.init(errorCode: errorCode, errorMessage: errorMessage)))
        }
        
        switch section {
        case PhantomAction.connect.host:
            guard let phantomEncryptionPublickey = components?.getQueryItem(withKey: "phantom_encryption_public_key"),
                  let nonce = components?.getQueryItem(withKey: "nonce"),
                  let data = components?.getQueryItem(withKey: "data") else {
                return .failure(.invalidParameters)
            }
            
            var sharedSecretDapp: Data!
            return generateSharedSecretDapp(
                phantomEncryptionPublickey: phantomEncryptionPublickey
            ).flatMap {
                sharedSecretDapp = $0
                return decryptor.decryptPayload(
                    data: data,
                    nonce: nonce,
                    publicKey: phantomEncryptionPublickey,
                    sharedSecretDapp: sharedSecretDapp
                )
            }.flatMap {
                PhantomConnectResponseData.decode(data: $0)
            }.flatMap {
                .success(.onConnect(
                    response: PhantomConnectResponseData(
                        public_key: $0.public_key,
                        session: $0.session),
                    sharedSecretDapp: sharedSecretDapp,
                    phantomEncryptionPublickey: phantomEncryptionPublickey)
                )
            }
        case PhantomAction.disconnect.host:
            return .success(.onDisconnect)
        case PhantomAction.signTransaction.host:
            guard let nonce = components?.getQueryItem(withKey: "nonce"),
                  let data = components?.getQueryItem(withKey: "data") else {
                return .failure(.invalidParameters)
            }
            return decryptor.decryptPayload(
                data: data,
                nonce: nonce,
                publicKey: dappSession.phantomEncryptionPublickey!,
                sharedSecretDapp: dappSession.sharedSecretDapp!
            )
            .flatMap { PhantomSignTransactionResponseData.decode(data: $0) }
            .flatMap {.success(PhantomResponse.onSignTransaction(response: $0)) }
            
        case PhantomAction.signAllTransactions.host:
            guard let nonce = components?.getQueryItem(withKey: "nonce"),
                  let data = components?.getQueryItem(withKey: "data") else {
                return .failure(.invalidParameters)
            }
            return decryptor.decryptPayload(
                data: data,
                nonce: nonce,
                publicKey: dappSession.phantomEncryptionPublickey!,
                sharedSecretDapp: dappSession.sharedSecretDapp!
            )
            .flatMap { PhantomSignAllTransactionsResponseData.decode(data: $0) }
            .flatMap {.success(PhantomResponse.onSignAllTransactions(response: $0)) }
            
        case PhantomAction.signAndSendTransaction.host:
            guard let nonce = components?.getQueryItem(withKey: "nonce"),
                  let data = components?.getQueryItem(withKey: "data") else {
                return .failure(.invalidParameters)
            }
            return decryptor.decryptPayload(
                data: data,
                nonce: nonce,
                publicKey: dappSession.phantomEncryptionPublickey!,
                sharedSecretDapp: dappSession.sharedSecretDapp!
            )
            .flatMap { PhantomSignAndSendTransactionResponseData.decode(data: $0) }
            .flatMap {.success(PhantomResponse.onSignAndSendTransaction(response: $0)) }
            
        case PhantomAction.signMessage.host:
            guard let nonce = components?.getQueryItem(withKey: "nonce"),
                  let data = components?.getQueryItem(withKey: "data") else {
                return .failure(.invalidParameters)
            }
            return decryptor.decryptPayload(
                data: data,
                nonce: nonce,
                publicKey: dappSession.phantomEncryptionPublickey!,
                sharedSecretDapp: dappSession.sharedSecretDapp!
            )
            .flatMap { PhantomSignMessageResponseData.decode(data: $0) }
            .flatMap {.success(PhantomResponse.onSignMessage(response: $0)) }
        default:
            return .failure(.hostNotSupported("\(section ?? "")"))
        }
    }
    
    private func generateSharedSecretDapp(phantomEncryptionPublickey: String) -> Result<Data, PhantomError> {
        do {
            let sharedSecret = try NaclBox.before(
                publicKey: Data(Base58.decode(phantomEncryptionPublickey)),
                secretKey: dappKeyPair.secretKey
            )
            return .success(sharedSecret)
        } catch let error {
            return .failure(.couldNotGenerateSharedSecret(error))
        }
    }
    
    private func redirectLinkString(host: PhantomAction) -> String {
        return "\(urlSchema)://\(host.host)"
    }
}

extension URLComponents {
    func getQueryItem(withKey: String) -> String? {
        return self.queryItems?.first(where: { $0.name == withKey })?.value
    }
}
