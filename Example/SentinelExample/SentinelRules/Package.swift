// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SentinelRules",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "../../.."),
    ],
    targets: [
        .executableTarget(
            name: "SentinelRules",
            dependencies: [
                .product(name: "SentinelKit", package: "sentinel"),
            ],
            path: "Sources"
        ),
    ]
)
