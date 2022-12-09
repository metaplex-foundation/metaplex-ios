# Metaplex IOS SDK

This SDK helps developers get started with the on-chain tools provided by Metaplex. It focuses its API on common use-cases to provide a smooth developer experience. 

⚠️ Please note that this SDK has been implemented from scratch and is currently in alpha. This means some of the core API and interfaces might change from one version to another. Feel free to contact me about bugs, improvements and new use cases. 

Please check the [Sample App](https://github.com/metaplex-foundation/metaplex-ios/tree/main/Sample).

## Installation

From Xcode 11, you can use [Swift Package Manager](https://swift.org/package-manager/) to add Solana.swift to your project.

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/metaplex-foundation/metaplex-ios`
- Select "brach" with "main"
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

- [`create(input, callback)`](#create)
- [`findByAddress(address, callback)`](#findByAddress)
- [`findByCreatorAndMint(creator, treasuryMint, callback)`](#findByCreatorAndMint)

All the methods return a callback. It's also possible to wrap them inside either RX, an async Result or Combine. We only provide this interface since it's the most compatible without forcing any specific framework. 

### create

The `create` method accepts properties that fills `CreateAuctionHouseInput` where `sellerFeeBasisPoints` is required to share part of the sale with the Auction House. Upon sucessful creation you will get an `Auctionhouse` object back.

```swift
public func create(
    sellerFeeBasisPoints: UInt16,
    requiresSignOff: Bool = false,
    canChangeSalePrice: Bool = false,
    auctioneerScopes: [AuthorityScope] = [],
    treasuryMint: PublicKey = PublicKey(string: "So11111111111111111111111111111111111111112")!,
    payer: Account? = nil,
    authority: Account? = nil,
    feeWithdrawalDestination: Account? = nil,
    treasuryWithdrawalDestinationOwner: PublicKey? = nil,
    auctioneerAuthority: PublicKey? = nil,
    onComplete: @escaping (Result<Auctionhouse, OperationError>) -> Void
) { ... }
```

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

- [`bid(input, callback)`](#bid)
- [`findBidByReceipt(address, auctionHouse, callback)`](#findBidByReceipt)
- [`findBidByTradeState(address, auctionHouse, callback)`](#findBidByTradeState)
- [`findBidsBy(type, auctionHouse, callback)`](#findBidsBy)
- [`loadBid(bid, callback)`](#loadBid)
- [`cancelBid(auctioneerAuthority, auctionHouse, bid, callback)`](#cancelBid)

### bid

The `bid` method takes in parameters in order to fill the `CreateBidInput` struct in order to create a `Bid` on Auction House. The only required parameter is the `AuctionhouseArgs`, which are the properties that make up an `Auctionhouse` object. With all of the parameters set to their default you will have a basic `Bid` that uses the identity of the `IdentityDriver`.

```swift
public func bid(
    auctionHouse: AuctionhouseArgs,
    buyer: Account? = nil,
    authority: Account? = nil,
    auctioneerAuthority: Account? = nil,
    mintAccount: PublicKey,
    seller: PublicKey? = nil,
    tokenAccount: PublicKey? = nil,
    price: UInt64? = 0,
    tokens: UInt64? = 1,
    printReceipt: Bool = true,
    bookkeeper: Account? = nil,
    onComplete: @escaping (Result<Bid, OperationError>) -> Void
) { ... }
```

### findBidByReceipt

The `findBidByReceipt` takes a `PublicKey` address and an Auction House, using `AuctionhouseArgs` in order to find the bid on the Auction House. In your app you could create an `Auctionhouse` using `create(input, callback)` or find an auction house with `findByAddress(address, callback)` or `findByCreatorAndMint(creator, treasuryMint, callback)`.

```swift
public func findBidByReceipt(
    _ address: PublicKey,
    auctionHouse: AuctionhouseArgs,
    onComplete: @escaping (Result<Bid, OperationError>) -> Void
) { ... }
```

### findBidByTradeState

The `findBidByTradeState` is identical to `findBidByReceipt` except now you are using the trade state `PublicKey` to find the bid on the `AuctionhouseArgs` passed in.

```swift
public func findBidByTradeState(
    _ address: PublicKey,
    auctionHouse: Auctionhouse,
    onComplete: @escaping (Result<Bid, OperationError>) -> Void
) { ... }
```

### findBidsBy

`findBidsBy` uses `BidPublicKeyType` to find multiple bids on the Auction House you provide using `AuctionhouseArgs`. The supported types are `buyer`, `metadata`, and `mint`.

```swift
enum BidPublicKeyType {
    case buyer(PublicKey)
    case metadata(PublicKey)
    case mint(PublicKey)
}

public func findBidsBy(
    type: BidPublicKeyType,
    auctionHouse: AuctionhouseArgs,
    onComplete: @escaping (Result<[Bidreceipt], OperationError>) -> Void
) { ... }
```

### loadBid

Use `loadBid` to finish loading the `LazyBid` with an asset, `NFT`, for a particular bid on the Auction House.

```swift
public func loadBid(_ bid: LazyBid, onComplete: @escaping (Result<Bid, OperationError>) -> Void) { ... }
```

### cancelBid

Cancel a bid on the Auction House using `cancelBid`. A `Bid` object is required and you cannot use a `LazyBid`.

```swift
public func cancelBid(
    auctioneerAuthority: Account? = nil,
    auctionHouse: AuctionhouseArgs,
    bid: Bid,
    onComplete: @escaping (Result<SignatureStatus, OperationError>) -> Void
) { ... }
```

### Bid

`Bid` is an object that consists of a `LazyBid` and an `NFT`. Sometimes you will only have `LazyBid` or a `Bidreceipt`. You can create a `Bid` object from these using the `loadBid(bid, callback)` method. A `LazyBid` can be created using an `Auctionhouse` and `Bidreceipt` to be passed into `loadBid(bid, callback)`.

```swift
public struct Bid {
    public let bidReceipt: LazyBid
    public let nft: NFT
}
```

### LazyBid

`LazyBid` is a partially loaded `Bid`. It's created from a `BidReceipt` and can be passed to `loadBid(bid, callback)` to fetch the asset in order to have access to the full `Bid` object.

```swift
public struct LazyBid {
    public let auctionHouse: AuctionhouseArgs
    public let tradeState: Pda
    public let bookkeeper: PublicKey?
    public let buyer: PublicKey
    public let metadata: PublicKey
    public let tokenAddress: PublicKey?
    public let receipt: Pda?
    public let purchaseReceipt: PublicKey?
    public let price: UInt64
    public let tokenSize: UInt64
    public let createdAt: Int64
    public let canceledAt: Int64?
}
```

### Bidreceipt

`Bidreceipt` is the low-level data that the Auction House program uses to return raw `Bid` data. Since we are working with raw data here we don't have access to the `NFT` and has to be loaded using the `loadBid(bid, callback)` method to create a usable higher level `Bid` object.

```swift
public struct Bidreceipt: BidreceiptArgs {
    public static let bidReceiptDiscriminator = [97, 99, 99, 111, 117, 110, 116, 58] as [UInt8]

    public let bidReceiptDiscriminator: [UInt8]
    public let tradeState: PublicKey
    public let bookkeeper: PublicKey
    public let auctionHouse: PublicKey
    public let buyer: PublicKey
    public let metadata: PublicKey
    public let tokenAccount: COption<PublicKey>
    public let purchaseReceipt: COption<PublicKey>
    public let price: UInt64
    public let tokenSize: UInt64
    public let bump: UInt8
    public let tradeStateBump: UInt8
    public let createdAt: Int64
    public let canceledAt: COption<Int64>
}
```

## Listing

Listing is a part of the `AuctionHouseClient` and allows you to list, find, and cancel listings using the following methods:

- [`list(input, callback)`](#list)
- [`findListingByReceipt(address, auctionHouse, callback)`](#findListingByReceipt)
- [`loadListing(listing, callback)`](#loadListing)
- [`cancelListing(auctioneerAuthority, auctionHouse, listing, callback)`](#cancelListing)

### list

The `list` method takes in parameters in order to fill the `CreateListingInput` struct in order to create a `Listing` on Auction House. The required parameters are the `AuctionhouseArgs` and a `UInt64` representing the price you want to charge. With all of the parameters set to their default you will have a basic `Listing` that uses the identity of the `IdentityDriver`.

```swift
public func list(
    auctionHouse: AuctionhouseArgs,
    seller: Account? = nil,
    authority: Account? = nil,
    auctioneerAuthority: Account? = nil,
    mintAccount: PublicKey,
    tokenAccount: PublicKey? = nil,
    price: UInt64,
    tokens: UInt64 = 1,
    printReceipt: Bool = true,
    bookkeeper: Account? = nil,
    onComplete: @escaping (Result<Listing, OperationError>) -> Void
) { ... }
```

### findListingByReceipt

The `findListingByReceipt` takes a `PublicKey` address and an Auction House, using `AuctionhouseArgs` in order to find the listing on the Auction House. In your app you could create an `Auctionhouse` using `create(input, callback)` or find an auction house with `findByAddress(address, callback)` or `findByCreatorAndMint(creator, treasuryMint, callback)`.

```swift
public func findListingByReceipt(
    _ address: PublicKey,
    auctionHouse: AuctionhouseArgs,
    onComplete: @escaping (Result<Listing, OperationError>) -> Void
) { ... }
```

### loadListing

Use `loadListing` to finish loading the `LazyListing` with an asset, `NFT`, for a particular listing on the Auction House.

```swift
public func loadListing(_ listing: LazyListing, onComplete: @escaping (Result<Listing, OperationError>) -> Void) { ... }
```

### cancelListing

Cancel a listing on the Auction House using `cancelListing`. A `Listing` object is required and you cannot use a `LazyListing`.

```swift
public func cancelListing(
    auctioneerAuthority: Account? = nil,
    auctionHouse: Auctionhouse,
    listing: Listing,
    onComplete: @escaping (Result<SignatureStatus, OperationError>) -> Void
) { ... }
```

### Listing

`Listing` is an object that consists of a `LazyListing` and an `NFT`. Sometimes you will only have `LazyListing` or a `Listingreceipt`. You can create a `Listing` object from these using the `loadListing(listing, callback)` method. A `LazyListing` can be created using an `Auctionhouse` and `Listingreceipt` to be passed into `loadListing(listing, callback)`.

```swift
public struct Listing {
    public let listingReceipt: LazyListing
    public let nft: NFT
}
```

### LazyListing

`LazyListing` is a partially loaded `Listing`. It's created from a `ListingReceipt` and can be passed to `loadListing(listing, callback)` to fetch the asset in order to have access to the full `Listing` object.

```swift
public struct LazyListing {
    public let auctionHouse: AuctionhouseArgs
    public let tradeState: Pda
    public let bookkeeper: PublicKey?
    public let seller: PublicKey
    public let metadata: PublicKey
    public let receipt: Pda?
    public let purchaseReceipt: PublicKey?
    public let price: UInt64
    public let tokenSize: UInt64
    public let createdAt: Int64
    public let canceledAt: Int64?
}
```

### Listingreceipt

`Bidreceipt` is the low-level data that the Auction House program uses to return raw `Bid` data. Since we are working with raw data here we don't have access to the `NFT` and has to be loaded using the `loadBid(bid, callback)` method to create a usable higher level `Bid` object.

```swift
public struct Listingreceipt: ListingreceiptArgs {
    public static let listingReceiptDiscriminator = [97, 99, 99, 111, 117, 110, 116, 58] as [UInt8]

    public let listingReceiptDiscriminator: [UInt8]
    public let tradeState: PublicKey
    public let bookkeeper: PublicKey
    public let auctionHouse: PublicKey
    public let seller: PublicKey
    public let metadata: PublicKey
    public let purchaseReceipt: COption<PublicKey>
    public let price: UInt64
    public let tokenSize: UInt64
    public let bump: UInt8
    public let tradeStateBump: UInt8
    public let createdAt: Int64
    public let canceledAt: COption<Int64>
}
```

## Sale

Listing is a part of the `AuctionHouseClient` and allows you to list, find, and cancel listings using the following methods:

- [`executeSale(input, callback)`](#executeSale)
- [`findPurchaseByReceipt(address, auctionHouse, callback)`](#findPurchaseByReceipt)
- [`loadPurchase(purchase, callback)`](#loadPurchase)

### executeSale

The `executeSale` method takes in parameters in order to fill the `ExecuteSaleInput` struct in order to execute the `Purchase` on the Auction House. The required parameters are the `AuctionhouseArgs`, along with the `Bid`, and `Listing` required for the sale. With the remaining parameters set to their default you will execute the sale using the identity of the `IdentityDriver`.

```swift
public func executeSale(
    bid: Bid,
    listing: Listing,
    auctionHouse: AuctionhouseArgs,
    auctioneerAuthority: Account? = nil,
    bookkeeper: Account? = nil,
    printReceipt: Bool = true,
    onComplete: @escaping (Result<Purchase, OperationError>) -> Void
) { ... }
```

### findPurchaseByReceipt

The `findPurchaseByReceipt` takes a `PublicKey` address and an Auction House, using `AuctionhouseArgs` in order to find the purchase on the Auction House. In your app you could create an `Auctionhouse` using `create(input, callback)` or find an auction house with `findByAddress(address, callback)` or `findByCreatorAndMint(creator, treasuryMint, callback)`.

```swift
public func findPurchaseByReceipt(
    _ address: PublicKey,
    auctionHouse: AuctionhouseArgs,
    onComplete: @escaping (Result<Purchase, OperationError>) -> Void
) { ... }
```

### loadPurchase

Use `loadPurchase` to finish loading the `LazyPurchase` with an asset, `NFT`, for a particular listing on the Auction House.

```swift
public func loadPurchase(_ purchase: LazyPurchase, onComplete: @escaping (Result<Purchase, OperationError>) -> Void) { ... }
```

### Purchase

`Purchase` is an object that consists of a `LazyPurchase` and an `NFT`. Sometimes you will only have `LazyPurchase` or a `Purchasereceipt`. You can create a `Purchase` object from these using the `loadPurchase(purchase, callback)` method. A `LazyPurchase` can be created using an `Auctionhouse` and `Purchasereceipt` to be passed into `loadPurchase(purchase, callback)`.

```swift
public struct Purchase {
    public let purchaseReceipt: LazyPurchase
    public let nft: NFT
}
```

### LazyPurchase

`LazyPurchase` is a partially loaded `Purchase`. It's created from a `Purchasereceipt` and can be passed to `loadPurchase(purchase, callback)` to fetch the asset in order to have access to the full `Purchase` object.

```swift
public struct LazyPurchase {
    public let auctionHouse: AuctionhouseArgs
    public let buyer: PublicKey
    public let seller: PublicKey
    public let metadata: PublicKey
    public let bookkeeper: PublicKey
    public let receipt: PublicKey?
    public let price: UInt64
    public let tokenSize: UInt64
    public let createdAt: Int64
}
```

### Purchasereceipt

`Purchasereceipt` is the low-level data that the Auction House program uses to return raw `Purchase` data. Since we are working with raw data here we don't have access to the `NFT` and has to be loaded using the `loadPurchase(purchase, callback)` method to create a usable higher level `Purchase` object.

```swift
public struct Purchasereceipt: PurchasereceiptArgs {
    public static let purchaseReceiptDiscriminator = [97, 99, 99, 111, 117, 110, 116, 58] as [UInt8]

    public let purchaseReceiptDiscriminator: [UInt8]
    public let bookkeeper: PublicKey
    public let buyer: PublicKey
    public let seller: PublicKey
    public let auctionHouse: PublicKey
    public let metadata: PublicKey
    public let tokenSize: UInt64
    public let price: UInt64
    public let bump: UInt8
    public let createdAt: Int64
}
```

You can [read more about Auction House in our online docs](https://docs.metaplex.com/programs/auction-house/overview).

## Candy Machine
The Candy Machine module can be accessed via `Metaplex.candyMachine` and provides the following methods. This is still a WIP and we are continuously adding more tests and documentation. These methods belong to the `CandyMachineClient` class. You can find more information below.

- [`create(input, callback)`](#create)
- [`mint(input, callback)`](#mint)
- [`findByAddress(address, callback)`](#findByAddress)

All the methods return a callback. It's also possible to wrap them inside either RX, an async Result or Combine. We only provide this interface since it's the most compatible without forcing any specific framework. 

### create

The `create` method accepts properties that fills `CreateCandyMachineInput` where `price`, `sellerFeeBasisPoints`, and `itemsAvailable` are required. Upon sucessful creation you will get a `CandyMachine` object back.

```swift
public func create(
    candyMachine: Account = HotAccount()!,
    wallet: Account? = nil,
    payer: Account? = nil,
    authority: Account? = nil,
    collection: PublicKey? = nil,
    tokenMint: PublicKey? = nil,
    price: UInt64,
    sellerFeeBasisPoints: UInt16,
    itemsAvailable: UInt64,
    symbol: String = "",
    maxEditionSupply: UInt64 = 0,
    isMutable: Bool = true,
    retainAuthority: Bool = true,
    goLiveDate: Int64? = nil,
    endSettings: EndSettings? = nil,
    hiddenSettings: HiddenSettings? = nil,
    whitelistMintSettings: WhitelistMintSettings? = nil,
    gatekeeper: GatekeeperConfig? = nil,
    creatorState: CreatorState? = nil,
    onComplete: @escaping (Result<CandyMachine, OperationError>) -> Void
) { ... }
```

### mint

The `mint` method accepts properties that fills `MintCandyMachineInput` where a `CandyMachine` is required. A `CandyMachine` should first be created on-chain and passed to the `mint` method. Upon sucessful creation you will get a `NFT` object back.

```swift
public func create(
        candyMachine: CandyMachine,
        payer: Account? = nil,
        newMint: Account = HotAccount()!,
        newOwner: PublicKey? = nil,
        newToken: PublicKey? = nil,
        payerToken: PublicKey? = nil,
        whitelistToken: PublicKey? = nil,
        onComplete: @escaping (Result<NFT, OperationError>) -> Void
) { ... }
```

### findByAddress

The `findByAddress` method accepts an `address` public key and returns a `CandyMachine` object.

```swift
let address = PublicKey(string: "5xN42RZCk7wA4GjQU2VVDhda8LBL8fAnrKZK921sybLF")!

metaplex.candyMachine.findByAddress(address) { result in
    switch result {
    case .success(let candyMachine):
        ...
    case .failure:
        ...
    }
}
```

### CandyMachine

`CandyMachine` is a wrapper around the auto-generated `Candymachine` object. `CandyMachine` also gives us easy access to the `CandyMachine` address. `CandyMachine` has convenient getters to access properties of `Candymachine`.

```swift
public struct CandyMachine {
    private let candyMachine: Candymachine
    let address: PublicKey

    public init(
        candyMachine: Candymachine,
        address: PublicKey
    ) {
        self.candyMachine = candyMachine
        self.address = address
    }

    public var authority: PublicKey { candyMachine.authority }
    public var wallet: PublicKey { candyMachine.wallet }
    public var tokenMint: PublicKey? { candyMachine.tokenMint }
    public var collectionMint: PublicKey? { nil }
    public var price: UInt64 { candyMachine.data.price }
    public var symbol: String { candyMachine.data.symbol }
    public var sellerFeeBasisPoints: UInt16 { candyMachine.data.sellerFeeBasisPoints }
    public var isMutable: Bool { candyMachine.data.isMutable }
    public var retainAuthority: Bool { candyMachine.data.retainAuthority }
    public var goLiveDate: Int64? { candyMachine.data.goLiveDate }
    public var maxEditionSupply: UInt64 { candyMachine.data.maxSupply }
    public var itemsAvailable: UInt64 { candyMachine.data.itemsAvailable }
    public var endSettings: EndSettings? { candyMachine.data.endSettings }
    public var hiddenSettings: HiddenSettings? { candyMachine.data.hiddenSettings }
    public var whitelistMintSettings: WhitelistMintSettings? { candyMachine.data.whitelistMintSettings }
    public var gatekeeper: GatekeeperConfig? { candyMachine.data.gatekeeper }
    public var creators: [Creator] { candyMachine.data.creators }
}
```

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

## Testing

Currently tests are a mix between `devnet`, `mainnet`, and locally using `amman`. We are in the process of getting `amman` working on CI in order to move all tests to the local validator.

All Auction House tests are set to run locally using `amman`, but are commented out so CI can pass. To run these tests you will need the [js sdk](git@github.com:metaplex-foundation/js.git). With the repo cloned, from the terminal run the following commands from the `js` directory:
```
yarn install
yarn amman:start
``` 

## Next steps
As mentioned above, this SDK is still in very early stages. We plan to add a lot more features to it. Here’s a quick overview of what we plan to work on next.
- New features in the NFT module.
- Upload, Create nfts to match Js-Next SDK.
- More documentation, tutorials, starter kits, etc.

## Acknowledgment

The SDK heavily inspired in the [JS-Next](https://github.com/metaplex-foundation/js-next). The objective of this is to have one Metaplex wide interface for all NFTs. If you use the Js-Next sdk this sdk should be familiar.

