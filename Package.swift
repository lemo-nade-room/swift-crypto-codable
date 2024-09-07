// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "crypto-codable",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CryptoCodable",
            targets: ["CryptoCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CryptoCodable"),
        .testTarget(
            name: "CryptoCodableTests",
            dependencies: [
                "CryptoCodable",
                .product(name: "Testing", package: "swift-testing"),
            ]),
    ]
)
