# Metaplex IOS SDK

This SDK helps developers get started with the on-chain tools provided by Metaplex. It focuses its API on common use-cases to provide a smooth developer experience. 

⚠️ Please note that this SDK has been implemented from scratch and is currently in alpha. This means some of the core API and interfaces might change from one version to another. Feel free to contact me about bugs, improvements and new use cases. 

Please check the [Sample App](https://github.com/metaplex-foundation/metaplex-ios/tree/main/Sample).

## Installation

From Xcode 11, you can use [Swift Package Manager](https://swift.org/package-manager/) to add Solana.swift to your project.

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/metaplex-foundation/metaplex-ios`
- Select "brach" with "master"
- Select Metaplex

If you encounter any problem or have a question on adding the package to an Xcode project, I suggest reading the [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)  guide article from Apple.

## Requirements

- iOS 11.0+ / macOS 10.13+ / tvOS 11.0+ / watchOS 3.0+
- Swift 5.3+

## Setup
The entry point to the Swift SDK is a `Metaplex` instance that will give you access to its API.

Set the `SolanaConnectionDriver` and setup your enviroment. Provide a `StorageDriver` and `IdentityDriver`. You can also use the concrete implementations URLSharedStorageDriver for URLShared and GuestIdentityDriver for a guest Indentity Driver. 

You can customise who the SDK should interact on behalf of and which storage provider to use when uploading assets. We might provide a default and simple implementation in the future.

```swift
let solanaDriver = SolanaConnectionDriver(endpoint: RPCEndpoint.mainnetBetaSolana)
let identityDriver = GuestIdentityDriver(solanaRPC: solana.solanaRPC)
let storageDriver = URLSharedStorageDriver(urlSession: URLSession.shared)
let metaplex Metaplex(connection: solana, identityDriver: identityDriver, storageDriver: storageDriver)
```

# Usage
Once properly configured, that `Metaplex` instance can be used to access modules providing different sets of features. Currently, there is only one NFT module that can be accessed via the `nft()` method. From that module, you will be able to find, create and update NFTs with more features to come.

Lets dive in nfts module. 

## NFTs
The NFT module can be accessed via `Metaplex.nft` and provide the following methods.

- [`findByMint(mint, callback)`](#findByMint)
- [`findAllByMintList(mints, callback)`](#findAllByMintList)
- [`findAllByOwner(owner, callback)`](#findAllByOwner)
- [`findAllByCreator(creator, position = 1, callback)`](#findAllByCreator)
- [`findAllByCandyMachine(candyMachine, version = 2, callback)`](#findAllByCandyMachine)
- [`createNft(input, callback)`](#createNft)

All the methods return a callback. It's also posible to wrap them inside either RX, an async Result or Combine. We only provide this interface since it's the most compatible without forcing any specific framework. 

### findByMint

The `findByMint` method accepts a `mint` public key and returns NFT object..

```swift
let ownerPublicKey = PublicKey(string: "HG2gLyDxmYGUfNWnvf81bJQj38twnF2aQivpkxficJbn")!

let nft = metaplex.nft.findByMint(publicKey: mintPublicKey) { result in
    switch result {
    case .success(let nft):
        ...
    case .failure:
        ...
    }
}
```

The returned `Nft` object. This nft will be not contain json data. It will only contain on-chain data. If you need access to the JSON offchain Metadata you can call. This call requires the metaplex object.

```swift
nft.metadata(metaplex: self.metaplex) { result in
    switch result {
    case .success(let metadata):
        ...
    case .failure:
        ...
    }
}
```

Similarly, the `MasterEditionAccount` account of the NFT will also be already loaded and, if it exists on that NFT, you can use it like so.

```swift
let masterEdition = nft.masterEditionAccount
```

Depending on the MasterEditionAccount version it can return v1 or v2 enums. 

You can [read more about the `NFT` model below](#the-nft-model).

### findAllByMintList

The `findAllByMintList` method accepts an array of mint addresses and returns an array of `Nft`s. However, `nil` values will be returned for each provided mint address that is not associated with an NFT.

```swift
let nft = metaplex.nft.findAllByMintList(mintKeys: [mintPublicKey, mintPublicKey]) { result in
    switch result {
    case .success(let nfts):
        // You can use nftList.compactMap{ $0 } to remove nils
        ...
    case .failure:
        ...
    }
}
```

NFTs retrieved via `findAllByMintList` will not have their JSON metadata loaded because this would require one request per NFT and could be inefficient if you provide a long list of mint addresses. Additionally, you might want to fetch these on-demand, as the NFTs are being displayed on your web app for instance.

Thus, if you want to load the JSON metadata of an NFT, you may do this like so.

```swift
nft.metadata(metaplex: self.metaplex) { result in
    switch result {
    case .success(let metadata):
        ...
    case .failure:
        ...
    }
}
```

We'll talk more about these tasks when documenting [the `NFT` model](#the-nft-model).

### findAllByOwner

The `findAllByOwner` method accepts a public key and returns all `Nft`s owned by that owner public key.

```swift
metaplex.nft.findAllByOwner(publicKey: ownerPublicKey) { [weak self] result in
    switch result {
    case .success(let nftList):
        ...
    case .failure:
        ...
    }
}
```

Similarly to `findAllByMintList`, the returned `Nft`s will not have their JSON metadata. This method is used on the [Sample App](https://github.com/metaplex-foundation/metaplex-ios/tree/main/Sample).

### createNft

The `createNft` method accepts an input and returns the `Nft` minted from the input. When creating the input, `createNftInput` requires a `uri`. This is where the off-chain json lives and can be a personal storage, aws, arweave, nftstorage, etc. You will need to have this `uri` before minting your `Nft` with `createNft`.

You may mint the `Nft` with a new or existing `Account`. If you are generating a new account for the mint you use `AccountState.new(mintAccount)` or you can use an existing account `AccountState.existing(existingMintAccount)`. This tells the program whether or not to create and initialize a mint account or not.

```swift
metaplex.nft.createNft(input: createNftInput) { result in
    switch result {
    case .success(let nft):
    case .failure:
    }
}
```

Currently collections and verifying creators are not supported, but will be added in a future release. 

### The `Nft` model

All of the methods above either return or interact with an `Nft` object. The `Nft` object is a read-only data representation of your NFT that contains all the information you need at the top level.

You can see [its full data representation by checking the code](/Sources/Metaplex/Modules/NFTS/Models/NFT) but here is an overview of the properties that are available on the `Nft` object.

```swift
// Always loaded.
public let metadataAccount: MetadataAccount
    
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

// Sometimes loaded.
public let masterEditionAccount: MasterEditionAccount?
```

As you can see, some of the properties are loaded on demand. This is because they are not always needed and/or can be expensive to load.

In order to load these properties, you may run the `metadata` properties of the `Nft` object.

```swift
nft.metadata(metaplex: self.metaplex) { result in
    switch result {
    case .success(let metadata):
        ...
    case .failure:
        ...
    }
}
```

## Auction House
The Auction House module can be accessed via `Metaplex.auctionHouse` and provide the following methods. This is still a WIP and we are continuously adding more tests and documentation. These methods belong to the `AuctionHouseClient` class. `AuctionHouseClient` is separated into four sections currently. `AuctionHouse`, `Bid`, `Listing`, and `Sale`. You can find more information about them below.

- [`create(sellerFeeBasisPoints, auctioneerAuthority, callback)`](#create)
- [`findByAddress(address, callback)`](#findByAddress)
- [`findByCreatorAndMint(creator, treasuryMint, callback)`](#findByCreatorAndMint)

All the methods return a callback. It's also possible to wrap them inside either RX, an async Result or Combine. We only provide this interface since it's the most compatible without forcing any specific framework. 

### create

The `create` method accepts a `sellerFeeBasisPoints` and an optional `auctioneerAuthority` public key. Upon sucessful creation you will get an `Auctionhouse` object back.

### findByAddress

The `findByAddress` method accepts an `address` public key and returns an `Auctionhouse` object.

```swift
let address = PublicKey(string: "5xN42RZCk7wA4GjQU2VVDhda8LBL8fAnrKZK921sybLF")!

metaplex.auctionHouse.findByAddress(address) { result in
    switch result {
    case .success(let auctionHouse):
        ...
    case .failure:
        ...
    }
}
```

### findByCreatorAndMint

The `findByCreatorAndMint` method accepts a `creator` public key and `treasurymint` public key. It'll use these keys to derive a PDA and returns an `Auctionhouse` object.

```swift
let creator = PublicKey(string: "95emj1a33Ei7B6ciu7gbPm7zRMRpFGs86g5nK5NiSdEK")!    
let treasuryMint = PublicKey(string: "So11111111111111111111111111111111111111112")!

metaplex.auctionHouse.findByCreatorAndMint(creator, and: treasuryMint) { result in
    switch result {
    case .success(let auctionHouse):
        ...
    case .failure:
        ...
    }
}

```

The returned `Auctionhouse` object will contain details about the Auction House account on chain.

### Auctionhouse

The `Auctionhouse` object is a read-only data representation of the on chain Auction House and contains all the information you need at a top level. This model is generated by `solita-swift` and is found in the `metaplex-swift-program-library`.

```swift
public let auctionHouseDiscriminator: [UInt8] /* Auctionhouse.auctionHouseDiscriminator */
public let auctionHouseFeeAccount: PublicKey
public let auctionHouseTreasury: PublicKey
public let treasuryWithdrawalDestination: PublicKey
public let feeWithdrawalDestination: PublicKey
public let treasuryMint: PublicKey
public let authority: PublicKey
public let creator: PublicKey
public let bump: UInt8
public let treasuryBump: UInt8
public let feePayerBump: UInt8
public let sellerFeeBasisPoints: UInt16
public let requiresSignOff: Bool
public let canChangeSalePrice: Bool
public let escrowPaymentBump: UInt8
public let hasAuctioneer: Bool
public let auctioneerAddress: PublicKey /* `PublicKey.default` if `hasAuctioneer` is false */
public let scopes: [Bool] /* size: 7 */
```

## Bid

Bidding is a part of the `AuctionHouseClient` and allows you to create, find, and cancel bids using the following methods:



You can [read more about Auction House in our online docs](https://docs.metaplex.com/programs/auction-house/overview).

## Identity
The current identity of a `Metaplex` instance can be accessed via `metaplex.identity()` and provide information on the wallet we are acting on behalf of when interacting with the SDK.

This method returns an identity object with the following interface. All the methods required a solana api instance

```swift
public protocol IdentityDriver {
    var publicKey: PublicKey { get }
    func sendTransaction(serializedTransaction: String, onComplete: @escaping(Result<TransactionID, IdentityDriverError>) -> Void)
    func signTransaction(transaction: Transaction, onComplete: @escaping (Result<Transaction, IdentityDriverError>) -> Void)
    func signAllTransactions(transactions: [Transaction], onComplete: @escaping (Result<[Transaction?], IdentityDriverError>) -> Void)
}
```

The implementation of these methods depends on the concrete identity driver being used. For example use a KeypairIdentity or a Guest(no publickey added)

Let’s have a quick look at the concrete identity drivers available to us.

### GuestIdentityDriver

The `GuestIdentityDriver` driver is the simpliest identity driver. It is essentially a `null` driver that can be useful when we don’t need to send any signed transactions. It will return failure if you use `signTransaction` methods.


### KeypairIdentityDriver

The `KeypairIdentityDriver` driver accepts a `Account` object as a parameter.


### ReadOnlyIdentityDriver

The `KeypairIdentityDriver` driver accepts a `PublicKey` object as a parameter. Its a read only similar to the GUestIdentity but it has a the provided `PublicKey`. It will return failure if you use `signTransaction` methods.

## Storage

You may access the current storage driver using `metaplex.storage()` which will give you access to the following interface.

```swift
public protocol StorageDriver {
    func download(url: URL, onComplete: @escaping(Result<NetworkingResponse, StorageDriverError>) -> Void)
}
```

Curently its only used to retrive json data off-chain. 

### URLSharedStorageDriver

This will use URLShared networking. Which is the default iOS networking implmentation. This maybe the most useful call.

### MemoryStorageDriver

This will use return Empty Data object with 0 size. 

## Next steps
As mentioned above, this SDK is still in very early stages. We plan to add a lot more features to it. Here’s a quick overview of what we plan to work on next.
- New features in the NFT module.
- Upload, Create nfts to match Js-Next SDK.
- More documentation, tutorials, starter kits, etc.

## Acknowledgment

The SDK heavily inspired in the [JS-Next](https://github.com/metaplex-foundation/js-next). The objective of this is to have one Metaplex wide interface for all NFTs. If you use the Js-Next sdk this sdk should be familiar.

