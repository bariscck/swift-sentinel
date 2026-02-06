import Foundation

/// Main entry point for Sentinel code analysis.
public struct Sentinel {
    private init() {}

    /// Analyze all production and test code in the working directory.
    public static func productionAndTestCode(
        path: String = FileManager.default.currentDirectoryPath
    ) -> On & Excluding {
        SentinelScopeBuilder(path: path)
    }

    /// Analyze production code only (excludes Tests and Fixtures).
    public static func productionCode(
        path: String = FileManager.default.currentDirectoryPath
    ) -> On & Excluding {
        SentinelScopeBuilder(path: path, excludes: ["Tests", "Fixtures"])
    }

    /// Analyze test code only.
    public static func testCode(
        path: String = FileManager.default.currentDirectoryPath
    ) -> On & Excluding {
        SentinelScopeBuilder(path: path, includes: ["Tests", "Fixtures"])
    }

    /// Analyze a specific folder within the working directory.
    public static func on(
        folder: String,
        path: String = FileManager.default.currentDirectoryPath
    ) -> Excluding {
        SentinelScopeBuilder(path: path).on(folder)
    }

    /// Analyze source code provided as a string.
    public static func on(source: String) -> SentinelScope {
        SourceScope(source: source)
    }

    /// Analyze source code provided by a closure.
    public static func on(source: () -> String) -> SentinelScope {
        SourceScope(source: source())
    }
}

/// A scope backed by a single source string (for testing).
private struct SourceScope: SentinelScope {
    let swiftSource: SwiftSourceCode

    init(source: String) {
        self.swiftSource = SwiftSourceCode(source: source)
    }

    var sourceCode: [SwiftSourceCode] { [swiftSource] }

    func classes(includeNested: Bool) -> [Class] { swiftSource.classes(includeNested: includeNested) }
    func structs(includeNested: Bool) -> [Struct] { swiftSource.structs(includeNested: includeNested) }
    func enums(includeNested: Bool) -> [Enum] { swiftSource.enums(includeNested: includeNested) }
    func protocols(includeNested: Bool) -> [ProtocolDeclaration] { swiftSource.protocols(includeNested: includeNested) }
    func functions(includeNested: Bool) -> [Function] { swiftSource.functions(includeNested: includeNested) }
    func variables(includeNested: Bool) -> [Variable] { swiftSource.variables(includeNested: includeNested) }
    func initializers(includeNested: Bool) -> [Initializer] { swiftSource.initializers(includeNested: includeNested) }
    func extensions() -> [Extension] { swiftSource.extensions() }
    func imports() -> [Import] { swiftSource.imports() }
}
