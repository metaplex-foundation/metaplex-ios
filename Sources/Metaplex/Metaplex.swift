public protocol Connection { }

public protocol IdentityDriver { }

class MockIdentityDriver: IdentityDriver { }

public protocol StorageDriver { }

class MockStorageDriver: StorageDriver { }


public class Metaplex {
    private let connection: Connection
    private var identityDriver: IdentityDriver
    private var storageDriver: StorageDriver
    public init(connection: Connection) {
        self.connection = connection
        self.identityDriver = MockIdentityDriver()
        self.storageDriver = MockStorageDriver()
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
}
