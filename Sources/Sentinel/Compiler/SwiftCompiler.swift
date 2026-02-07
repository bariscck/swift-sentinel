import Foundation

/// Compiles and runs rule files by generating a temporary SPM package.
///
/// Instead of calling `swiftc` directly (which requires manually resolving all transitive
/// dependencies like SwiftSyntax), this generates a minimal SPM executable package in a
/// temp directory that depends on SentinelKit. SPM handles all dependency resolution.
struct SwiftCompiler {

    enum CompilerError: Error, CustomStringConvertible {
        case compilationFailed(String)
        case sentinelPackageNotFound

        var description: String {
            switch self {
            case .compilationFailed(let output):
                return "Rule compilation failed:\n\(output)"
            case .sentinelPackageNotFound:
                return "Could not resolve Sentinel package path. Ensure sentinel is run from within the Sentinel package or pass --sentinel-path."
            }
        }
    }

    /// Compile rule files into an executable via a temporary SPM package.
    ///
    /// - Parameters:
    ///   - ruleFiles: Paths to rule `.swift` files.
    ///   - mainSource: Generated main.swift source code.
    ///   - sentinelPackagePath: Path to the root Sentinel package (for local dependency).
    /// - Returns: Path to the compiled executable.
    static func compile(
        ruleFiles: [URL],
        mainSource: String,
        sentinelPackagePath: String
    ) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("sentinel-\(ProcessInfo.processInfo.globallyUniqueString)")
        let sourcesDir = tempDir.appendingPathComponent("Sources")

        try FileManager.default.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

        // 1. Write Package.swift
        let packageManifest = generatePackageManifest(sentinelPackagePath: sentinelPackagePath)
        let packageFile = tempDir.appendingPathComponent("Package.swift")
        try packageManifest.write(to: packageFile, atomically: true, encoding: .utf8)

        // 2. Copy rule files into Sources/
        for ruleFile in ruleFiles {
            let dest = sourcesDir.appendingPathComponent(ruleFile.lastPathComponent)
            // Avoid name collisions by prefixing with hash if needed
            if FileManager.default.fileExists(atPath: dest.path) {
                let uniqueName = "\(ruleFile.deletingPathExtension().lastPathComponent)_\(abs(ruleFile.path.hashValue)).swift"
                let uniqueDest = sourcesDir.appendingPathComponent(uniqueName)
                try FileManager.default.copyItem(at: ruleFile, to: uniqueDest)
            } else {
                try FileManager.default.copyItem(at: ruleFile, to: dest)
            }
        }

        // 3. Write generated main.swift
        let mainFile = sourcesDir.appendingPathComponent("main.swift")
        try mainSource.write(to: mainFile, atomically: true, encoding: .utf8)

        // 4. Build with SPM
        let buildProcess = Process()
        buildProcess.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        buildProcess.arguments = ["build", "--package-path", tempDir.path, "-c", "debug"]
        buildProcess.currentDirectoryURL = tempDir

        let buildPipe = Pipe()
        buildProcess.standardOutput = buildPipe
        buildProcess.standardError = buildPipe

        try buildProcess.run()
        buildProcess.waitUntilExit()

        let buildOutput = String(
            data: buildPipe.fileHandleForReading.readDataToEndOfFile(),
            encoding: .utf8
        ) ?? ""

        guard buildProcess.terminationStatus == 0 else {
            throw CompilerError.compilationFailed(buildOutput)
        }

        // 5. Return path to built executable
        let executablePath = tempDir
            .appendingPathComponent(".build")
            .appendingPathComponent("debug")
            .appendingPathComponent("SentinelRuleRunner")

        return executablePath
    }

    /// Generate a Package.swift manifest for the temporary package.
    private static func generatePackageManifest(sentinelPackagePath: String) -> String {
        let escapedPath = sentinelPackagePath.replacingOccurrences(of: "\"", with: "\\\"")
        return """
        // swift-tools-version: 6.2
        import PackageDescription

        let package = Package(
            name: "SentinelRuleRunner",
            platforms: [.macOS(.v13)],
            dependencies: [
                .package(path: "\(escapedPath)"),
            ],
            targets: [
                .executableTarget(
                    name: "SentinelRuleRunner",
                    dependencies: [
                        .product(name: "SentinelKit", package: "sentinel"),
                    ],
                    path: "Sources"
                ),
            ]
        )
        """
    }
}
