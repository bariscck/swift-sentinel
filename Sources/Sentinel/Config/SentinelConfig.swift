import Foundation

/// Configuration model parsed from `.sentinel.yml`.
struct SentinelConfig: Sendable {
    /// Rule file or directory paths (relative to config file location).
    let rules: [String]

    /// Paths to exclude from analysis.
    let exclude: [String]

    /// Paths to include in analysis (if empty, all paths are included).
    let include: [String]

    init(rules: [String] = [], exclude: [String] = [], include: [String] = []) {
        self.rules = rules
        self.exclude = exclude
        self.include = include
    }
}
