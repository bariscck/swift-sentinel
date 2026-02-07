// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Sentinel",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .executable(name: "sentinel", targets: ["Sentinel"]),
        .library(name: "SentinelKit", targets: ["SentinelKit"]),
        .library(name: "SentinelCore", targets: ["SentinelCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "SentinelCore",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SentinelKit",
            dependencies: ["SentinelCore"]
        ),
        .executableTarget(
            name: "Sentinel",
            dependencies: [
                "SentinelKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "SentinelCoreTests",
            dependencies: ["SentinelCore"]
        ),
        .testTarget(
            name: "SentinelKitTests",
            dependencies: ["SentinelKit"]
        ),
        .testTarget(
            name: "SentinelTests",
            dependencies: ["SentinelKit"]
        ),
    ]
)
