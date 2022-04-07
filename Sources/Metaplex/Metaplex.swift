import Solana

public class Metaplex {
    private let connection: Connection
    private var identityDriver: IdentityDriver
    private var storageDriver: StorageDriver
    public init(connection: Connection, identityDriver: IdentityDriver, storageDriver: StorageDriver) {
        self.connection = connection
        self.identityDriver = identityDriver
        self.storageDriver = storageDriver
    }
    
    func identity() -> IdentityDriver {
        return self.identityDriver
    }
    
    func setIdentity(identityDriver: IdentityDriver) -> IdentityDriver{
        self.identityDriver = identityDriver
        return self.identityDriver
    }
    
    func storage() -> StorageDriver {
        return self.storageDriver
    }
    
    func setStorage(storageDriver: StorageDriver) -> StorageDriver {
        self.storageDriver = storageDriver
        return self.storageDriver
    }
    
    func getAccountInfo(account: String, onComplete: @escaping (Result<BufferInfo<AccountInfo>, Error>) -> Void){
        return self.connection.getAccountInfo(account: account, onComplete: onComplete)
    }
    
    func getMultipleAccounts(accounts: [String], onComplete: @escaping (Result<[BufferInfo<AccountInfo>], Error>) -> Void){
        return self.connection.getMultipleAccountsInfo(accounts: accounts, onComplete: onComplete)
    }
    
    func sendTransaction(serializedTransaction: String, onComplete: @escaping(Result<TransactionID, Error>) -> Void){
        self.identityDriver.sendTransaction(serializedTransaction: serializedTransaction, onComplete: onComplete)
    }
    
    func confirmTransaction(signature: String, configs: RequestConfiguration?, onComplete: @escaping (Result<SignatureStatus?, Error>) -> Void){
        self.connection.confirmTransaction(signature: signature, configs: configs) { signatureResult in
            switch signatureResult {
            case .success(let signatures):
                onComplete(.success(signatures.first ?? nil))
            case .failure(let error):
                onComplete(.failure(error))
            }
        }
    }
    
    func sendAndConfirmTransaction(serializedTransaction: String, configs: RequestConfiguration?, onComplete: @escaping (Result<SignatureStatus?, Error>) -> Void){
        self.sendTransaction(serializedTransaction: serializedTransaction) { result in
            switch result{
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
