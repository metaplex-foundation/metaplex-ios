import Solana

public class Metaplex {
    let connection: Connection
    private var identityDriver: IdentityDriver
    private var storageDriver: StorageDriver

    public lazy var nft: NftClient = NftClient(metaplex: self)

    public init(connection: Connection, identityDriver: IdentityDriver, storageDriver: StorageDriver) {
        self.connection = connection
        self.identityDriver = identityDriver
        self.storageDriver = storageDriver
    }

    public func identity() -> IdentityDriver {
        return self.identityDriver
    }

    public func setIdentity(identityDriver: IdentityDriver) -> IdentityDriver {
        self.identityDriver = identityDriver
        return self.identityDriver
    }

    public func storage() -> StorageDriver {
        return self.storageDriver
    }

    public func setStorage(storageDriver: StorageDriver) -> StorageDriver {
        self.storageDriver = storageDriver
        return self.storageDriver
    }

    public func getAccountInfo<T>(account: PublicKey, decodedTo: T.Type, onComplete: @escaping (Result<BufferInfo<T>, Error>) -> Void) {
        return self.connection.getAccountInfo(account: account, decodedTo: T.self, onComplete: onComplete)
    }

    public func getMultipleAccounts<T>(accounts: [PublicKey], decodedTo: T.Type, onComplete: @escaping (Result<[BufferInfo<T>?], Error>) -> Void) {
        return self.connection.getMultipleAccountsInfo(accounts: accounts, decodedTo: T.self, onComplete: onComplete)
    }

    public func sendTransaction(serializedTransaction: String, onComplete: @escaping(Result<TransactionID, IdentityDriverError>) -> Void) {
        self.identityDriver.sendTransaction(serializedTransaction: serializedTransaction, onComplete: onComplete)
    }

    public func confirmTransaction(signature: String, configs: RequestConfiguration?, onComplete: @escaping (Result<SignatureStatus?, Error>) -> Void) {
        self.connection.confirmTransaction(signature: signature, configs: configs) { signatureResult in
            switch signatureResult {
            case .success(let signatures):
                onComplete(.success(signatures.first ?? nil))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }

    public func sendAndConfirmTransaction(serializedTransaction: String, configs: RequestConfiguration?, onComplete: @escaping (Result<SignatureStatus?, Error>) -> Void) {
        self.sendTransaction(serializedTransaction: serializedTransaction) { result in
            switch result {
            case .success(let signature):
                self.confirmTransaction(signature: signature, configs: configs) { signatureResult in
                    onComplete(signatureResult)
                }
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
}
