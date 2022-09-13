// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Metaplex",
    platforms: [.iOS(.v11),.macOS(.v10_12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Metaplex",
            targets: ["Metaplex"]),
    ],
    dependencies: [
        .package(url: "https://github.com/metaplex-foundation/Solana.Swift.git", branch: "1.3.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Metaplex",
            dependencies: [.product(name: "Solana", package: "Solana.Swift")]),
        .testTarget(
            name: "MetaplexTests",
            dependencies: ["Metaplex"]),
    ]
)
