import Foundation
import CryptoKit

/// Compiles and runs rule files by generating a temporary SPM package.
///
/// Instead of calling `swiftc` directly (which requires manually resolving all transitive
/// dependencies like SwiftSyntax), this generates a minimal SPM executable package in a
/// temp directory that depends on SentinelKit. SPM handles all dependency resolution.
///
/// Uses a stable cache directory with content-hash based invalidation:
/// - If rule files haven't changed since the last build, the cached binary is reused instantly.
/// - If rule files changed, only an incremental SPM build is triggered (~1-2s).
/// - First build from scratch takes ~15-30s (full dependency compilation).
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

    /// Stable cache directory for the temporary SPM package.
    private static var cacheDir: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("sentinel-rule-cache")
    }

    /// Path to the file storing the hash of the last successful build.
    private static var hashFile: URL {
        cacheDir.appendingPathComponent(".sentinel-sources-hash")
    }

    /// Compile rule files into an executable via a temporary SPM package.
    ///
    /// Uses content hashing to skip recompilation when rule files haven't changed.
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
        let packageDir = cacheDir
        let sourcesDir = packageDir.appendingPathComponent("Sources")
        let executablePath = packageDir
            .appendingPathComponent(".build")
            .appendingPathComponent("debug")
            .appendingPathComponent("SentinelRuleRunner")

        // Compute content hash from all rule sources + generated main + sentinel package path
        let currentHash = try computeSourcesHash(
            ruleFiles: ruleFiles,
            mainSource: mainSource,
            sentinelPackagePath: sentinelPackagePath
        )

        // Fast path: if hash matches and executable exists, skip compilation entirely
        if let previousHash = try? String(contentsOf: hashFile, encoding: .utf8),
           previousHash == currentHash,
           FileManager.default.fileExists(atPath: executablePath.path) {
            return executablePath
        }

        // Clean Sources/ so stale rule files don't linger, but keep .build/ for cache
        if FileManager.default.fileExists(atPath: sourcesDir.path) {
            try FileManager.default.removeItem(at: sourcesDir)
        }
        try FileManager.default.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

        // 1. Write Package.swift (overwrite each time in case sentinelPackagePath changed)
        let packageManifest = generatePackageManifest(sentinelPackagePath: sentinelPackagePath)
        let packageFile = packageDir.appendingPathComponent("Package.swift")
        try packageManifest.write(to: packageFile, atomically: true, encoding: .utf8)

        // 2. Copy rule files into Sources/
        for ruleFile in ruleFiles {
            let dest = sourcesDir.appendingPathComponent(ruleFile.lastPathComponent)
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

        // 4. Build with SPM (incremental if .build/ cache exists)
        let buildProcess = Process()
        buildProcess.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        buildProcess.arguments = ["build", "--package-path", packageDir.path, "-c", "debug"]
        buildProcess.currentDirectoryURL = packageDir

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
            // Remove stale hash on failure so next run retries
            try? FileManager.default.removeItem(at: hashFile)
            throw CompilerError.compilationFailed(buildOutput)
        }

        // 5. Save hash for future cache hits
        try currentHash.write(to: hashFile, atomically: true, encoding: .utf8)

        return executablePath
    }

    // MARK: - Private

    /// Compute a SHA256 hash of all source inputs to detect changes.
    ///
    /// Includes: rule file contents, generated main.swift, and sentinel package path.
    /// This ensures recompilation only happens when sources actually change.
    private static func computeSourcesHash(
        ruleFiles: [URL],
        mainSource: String,
        sentinelPackagePath: String
    ) throws -> String {
        var hasher = SHA256()

        // Hash sentinel package path (affects Package.swift dependency)
        hasher.update(data: Data(sentinelPackagePath.utf8))
        hasher.update(data: Data([0])) // separator

        // Hash each rule file's content (sorted by name for determinism)
        for ruleFile in ruleFiles.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            let content = try Data(contentsOf: ruleFile)
            hasher.update(data: Data(ruleFile.lastPathComponent.utf8))
            hasher.update(data: Data([0]))
            hasher.update(data: content)
            hasher.update(data: Data([0]))
        }

        // Hash generated main.swift
        hasher.update(data: Data(mainSource.utf8))

        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
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
