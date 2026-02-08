import Foundation

/// Configuration for a Sentinel run.
public struct Configuration: Sendable {
    public let projectPath: String
    public let includePaths: [String]
    public let excludePaths: [String]

    /// When non-empty, restricts analysis to only the specified file paths (absolute).
    /// Used by the `--changed-only` CLI flag to lint only git-changed files.
    public let changedFiles: [String]

    public init(
        projectPath: String = FileManager.default.currentDirectoryPath,
        includePaths: [String] = [],
        excludePaths: [String] = ["Tests"],
        changedFiles: [String] = []
    ) {
        self.projectPath = projectPath
        self.includePaths = includePaths
        self.excludePaths = excludePaths
        self.changedFiles = changedFiles
    }
}
