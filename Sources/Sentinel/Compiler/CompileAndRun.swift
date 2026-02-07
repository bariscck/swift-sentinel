import Foundation

/// Orchestrates the full Sentinel pipeline:
/// config parse → rule discovery → code generation → compilation → execution.
struct CompileAndRun {

    enum PipelineError: Error, CustomStringConvertible {
        case noRuleFiles(String)
        case noRuleTypes
        case executionFailed(Int32)

        var description: String {
            switch self {
            case .noRuleFiles(let paths):
                return "No Swift rule files found in paths: \(paths)"
            case .noRuleTypes:
                return "No Rule-conforming types found in rule files. Ensure your rules implement the Rule protocol."
            case .executionFailed(let code):
                return "Sentinel runner exited with code \(code)"
            }
        }
    }

    /// Run the full pipeline.
    ///
    /// - Parameters:
    ///   - config: Parsed Sentinel configuration.
    ///   - configDir: Directory containing the config file (for resolving relative paths).
    ///   - projectPath: Absolute path to the project being analyzed.
    ///   - sentinelPackagePath: Path to the root Sentinel SPM package.
    static func run(
        config: SentinelConfig,
        configDir: String,
        projectPath: String,
        sentinelPackagePath: String
    ) throws {
        // 1. Collect rule Swift files
        let ruleFiles = collectRuleFiles(paths: config.rules, baseDir: configDir)

        guard !ruleFiles.isEmpty else {
            throw PipelineError.noRuleFiles(config.rules.joined(separator: ", "))
        }

        // 2. Discover Rule-conforming types via SwiftSyntax
        let ruleTypeNames = RuleDiscovery.discoverRuleTypes(in: ruleFiles)

        guard !ruleTypeNames.isEmpty else {
            throw PipelineError.noRuleTypes
        }

        // 3. Generate main.swift
        let mainSource = MainGenerator.generate(
            ruleTypeNames: ruleTypeNames,
            projectPath: projectPath,
            excludePaths: config.exclude,
            includePaths: config.include
        )

        // 4. Compile via temporary SPM package
        let executable = try SwiftCompiler.compile(
            ruleFiles: ruleFiles,
            mainSource: mainSource,
            sentinelPackagePath: sentinelPackagePath
        )

        // 5. Execute and forward output
        let exitCode = try execute(executable: executable)

        // 6. Exit with same code
        // Note: cache directory is intentionally preserved for incremental builds.
        if exitCode != 0 {
            exit(exitCode)
        }
    }

    // MARK: - Private

    /// Collect all `.swift` files from the given rule paths.
    private static func collectRuleFiles(paths: [String], baseDir: String) -> [URL] {
        let fileManager = FileManager.default
        var files: [URL] = []

        for path in paths {
            let fullPath: String
            if path.hasPrefix("/") {
                fullPath = path
            } else {
                fullPath = (baseDir as NSString).appendingPathComponent(path)
            }

            var isDir: ObjCBool = false
            guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) else {
                print("Sentinel: Warning — rule path not found: \(path)")
                continue
            }

            if isDir.boolValue {
                // Enumerate all .swift files in directory
                if let enumerator = fileManager.enumerator(
                    at: URL(fileURLWithPath: fullPath),
                    includingPropertiesForKeys: [.isRegularFileKey],
                    options: [.skipsHiddenFiles]
                ) {
                    for case let fileURL as URL in enumerator {
                        if fileURL.pathExtension == "swift" {
                            files.append(fileURL)
                        }
                    }
                }
            } else if fullPath.hasSuffix(".swift") {
                files.append(URL(fileURLWithPath: fullPath))
            }
        }

        return files
    }

    /// Execute the compiled binary and forward stdout/stderr.
    private static func execute(executable: URL) throws -> Int32 {
        let process = Process()
        process.executableURL = executable

        // Forward stdout and stderr directly
        process.standardOutput = FileHandle.standardOutput
        process.standardError = FileHandle.standardError

        try process.run()
        process.waitUntilExit()

        return process.terminationStatus
    }
}
