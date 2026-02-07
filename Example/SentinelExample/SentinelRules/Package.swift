// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SentinelRules",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(name: "SentinelRules", targets: ["SentinelRules"]),
    ],
    dependencies: [
        .package(path: "../../.."),
    ],
    targets: [
        .target(
            name: "SentinelRules",
            dependencies: [
                .product(name: "SentinelKit", package: "sentinel"),
            ],
            path: "Sources"
        ),
    ]
)
