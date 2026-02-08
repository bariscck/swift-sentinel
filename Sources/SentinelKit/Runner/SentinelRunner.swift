import Foundation
import SentinelCore

/// Convenience entry point for running Sentinel rules.
/// Outputs diagnostics in Xcode-compatible format and exits with appropriate code.
public enum SentinelRunner {
    public static func run(
        rules: [any Rule],
        configuration: Configuration = Configuration()
    ) {
        let scope = SentinelScopeBuilder(
            path: configuration.projectPath,
            excludes: configuration.excludePaths,
            changedFiles: configuration.changedFiles
        )

        let runner = RuleRunner(rules: rules, scope: scope)
        let violations = runner.run()

        let sorted = violations.sorted { lhs, rhs in
            if lhs.filePath != rhs.filePath {
                return lhs.filePath < rhs.filePath
            }
            return lhs.line < rhs.line
        }

        for violation in sorted {
            print(XcodeDiagnosticFormatter.format(violation))
        }

        let errorCount = violations.filter { $0.severity == .error }.count
        let warningCount = violations.filter { $0.severity == .warning }.count
        let infoCount = violations.filter { $0.severity == .info }.count

        if !violations.isEmpty {
            let parts: [String] = [
                errorCount > 0 ? "\(errorCount) error(s)" : nil,
                warningCount > 0 ? "\(warningCount) warning(s)" : nil,
                infoCount > 0 ? "\(infoCount) info(s)" : nil,
            ].compactMap { $0 }
            let summary = parts.joined(separator: ", ")
            print("Sentinel: Found \(summary)")
        }

        if errorCount > 0 {
            exit(1)
        }
    }
}
