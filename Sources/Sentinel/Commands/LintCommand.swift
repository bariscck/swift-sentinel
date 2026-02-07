import ArgumentParser
import Foundation

struct LintCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "lint",
        abstract: "Lint Swift source files using @SentinelRule rules."
    )

    @Option(name: .shortAndLong, help: "Path to the config file.")
    var config: String = ".sentinel.yml"

    @Option(name: .shortAndLong, help: "Path to the project directory.")
    var path: String = FileManager.default.currentDirectoryPath

    @Option(name: .long, help: "Path to the Sentinel package (auto-detected if omitted).")
    var sentinelPath: String?

    func run() throws {
        let projectPath = (path as NSString).standardizingPath
        let configPath: String

        if (config as NSString).isAbsolutePath {
            configPath = config
        } else {
            configPath = (projectPath as NSString).appendingPathComponent(config)
        }

        // Parse config — use defaults if file doesn't exist
        let sentinelConfig: SentinelConfig
        if FileManager.default.fileExists(atPath: configPath) {
            do {
                sentinelConfig = try ConfigParser.parse(at: configPath)
            } catch {
                print("Sentinel: \(error)")
                throw ExitCode.failure
            }
        } else {
            sentinelConfig = SentinelConfig()
        }

        // Resolve Sentinel package path
        let resolvedSentinelPath: String
        if let explicit = sentinelPath {
            resolvedSentinelPath = (explicit as NSString).standardizingPath
        } else {
            resolvedSentinelPath = try resolveSentinelPackagePath()
        }

        // Determine config directory for resolving relative paths
        let configDir = (configPath as NSString).deletingLastPathComponent

        // Run pipeline
        do {
            try CompileAndRun.run(
                config: sentinelConfig,
                configDir: configDir,
                projectPath: projectPath,
                sentinelPackagePath: resolvedSentinelPath
            )
        } catch {
            print("Sentinel: \(error)")
            throw ExitCode.failure
        }
    }

    /// Resolve the Sentinel package root directory from the running binary.
    ///
    /// When run via `swift run --package-path <path> sentinel lint`, the binary is at
    /// `<path>/.build/debug/sentinel`. We walk up to find `Package.swift`.
    private func resolveSentinelPackagePath() throws -> String {
        let binaryPath = ProcessInfo.processInfo.arguments[0]
        let binaryURL = URL(fileURLWithPath: binaryPath).resolvingSymlinksInPath()

        // Walk up directory tree looking for Package.swift with name "Sentinel"
        var current = binaryURL.deletingLastPathComponent()
        for _ in 0..<10 {
            let packageFile = current.appendingPathComponent("Package.swift")
            if FileManager.default.fileExists(atPath: packageFile.path) {
                // Verify it's the Sentinel package
                if let content = try? String(contentsOf: packageFile, encoding: .utf8),
                   content.contains("\"Sentinel\"") || content.contains("\"SentinelKit\"") {
                    return current.path
                }
            }
            current = current.deletingLastPathComponent()
        }

        throw SwiftCompiler.CompilerError.sentinelPackageNotFound
    }
}
