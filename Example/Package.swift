// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SentinelExample",
    platforms: [.iOS(.v15), .macOS(.v13)],
    dependencies: [
        .package(name: "Sentinel", path: ".."),
    ],
    targets: [
        // The iOS app source code that Sentinel will lint
        .target(
            name: "App",
            path: "Sources/App"
        ),
        // Executable that runs Sentinel rules against the App target
        .executableTarget(
            name: "SentinelRules",
            dependencies: [
                .product(name: "SentinelKit", package: "Sentinel"),
            ],
            path: "Sources/SentinelRules"
        ),
    ]
)
