// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

let package = Package(
    name: "crypto-codable",
    platforms: [.macOS(.v12)],
    products: [
        .library(
            name: "CryptoCodable",
            targets: ["CryptoCodable"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0"),
        .package(url: "https://github.com/swiftlang/swift-docc-plugin.git", from: "1.0.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "CryptoCodable",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            plugins: swiftLintPlugins
        ),
        .testTarget(
            name: "CryptoCodableTests",
            dependencies: [
                "CryptoCodable",
                .product(name: "Testing", package: "swift-testing"),
            ],
            plugins: swiftLintPlugins
        ),
    ]
)

var swiftLintPlugins: [Target.PluginUsage] {
    guard Environment.enableSwiftLint else { return [] }
    return [
        .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
    ]
}

enum Environment {
    static func get(_ key: String) -> String? {
        ProcessInfo.processInfo.environment[key]
    }
    static var enableSwiftLint: Bool {
        Self.get("SWIFTLINT") == "true"
    }
}
