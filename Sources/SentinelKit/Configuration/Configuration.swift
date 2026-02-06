import Foundation

/// Configuration for a Sentinel run.
public struct Configuration: Sendable {
    public let projectPath: String
    public let includePaths: [String]
    public let excludePaths: [String]

    public init(
        projectPath: String = FileManager.default.currentDirectoryPath,
        includePaths: [String] = [],
        excludePaths: [String] = ["Tests"]
    ) {
        self.projectPath = projectPath
        self.includePaths = includePaths
        self.excludePaths = excludePaths
    }
}
