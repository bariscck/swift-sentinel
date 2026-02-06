import Foundation

/// Builds a SentinelScope from file discovery configuration.
public final class SentinelScopeBuilder: SentinelScope, On, Excluding, @unchecked Sendable {
    private let basePath: String
    private var folder: String?
    private var includePatterns: [String]
    private var excludePatterns: [String]

    nonisolated(unsafe) private static var sourceCodeCache = ConcurrentDictionary<String, [SwiftSourceCode]>()

    public init(path: String = FileManager.default.currentDirectoryPath,
                folder: String? = nil,
                includes: [String] = [],
                excludes: [String] = []) {
        self.basePath = path
        self.folder = folder
        self.includePatterns = includes
        self.excludePatterns = excludes
    }

    // MARK: - Builder Methods

    public func on(_ folder: String) -> Excluding {
        let copy = self.copy()
        copy.folder = folder
        return copy
    }

    public func excluding(_ excludes: String...) -> SentinelScope {
        excluding(excludes)
    }

    public func excluding(_ excludes: [String]) -> SentinelScope {
        let copy = self.copy()
        copy.excludePatterns.append(contentsOf: excludes)
        return copy
    }

    // MARK: - Source Code Access

    public var sourceCode: [SwiftSourceCode] {
        let cacheKey = "\(basePath)|\(folder ?? "")|\(includePatterns)|\(excludePatterns)"
        if let cached = Self.sourceCodeCache[cacheKey] {
            return cached
        }

        let files = GetFiles(
            path: basePath,
            folder: folder,
            includes: includePatterns,
            excludes: excludePatterns
        ).swiftFiles()

        let sources = files.compactMap { SwiftSourceCode.from(url: $0) }
        Self.sourceCodeCache[cacheKey] = sources
        return sources
    }

    // MARK: - SentinelScope

    public func classes(includeNested: Bool) -> [Class] {
        sourceCode.flatMap { $0.classes(includeNested: includeNested) }
    }

    public func structs(includeNested: Bool) -> [Struct] {
        sourceCode.flatMap { $0.structs(includeNested: includeNested) }
    }

    public func enums(includeNested: Bool) -> [Enum] {
        sourceCode.flatMap { $0.enums(includeNested: includeNested) }
    }

    public func protocols(includeNested: Bool) -> [ProtocolDeclaration] {
        sourceCode.flatMap { $0.protocols(includeNested: includeNested) }
    }

    public func functions(includeNested: Bool) -> [Function] {
        sourceCode.flatMap { $0.functions(includeNested: includeNested) }
    }

    public func variables(includeNested: Bool) -> [Variable] {
        sourceCode.flatMap { $0.variables(includeNested: includeNested) }
    }

    public func initializers(includeNested: Bool) -> [Initializer] {
        sourceCode.flatMap { $0.initializers(includeNested: includeNested) }
    }

    public func extensions() -> [Extension] {
        sourceCode.flatMap { $0.extensions() }
    }

    public func imports() -> [Import] {
        sourceCode.flatMap { $0.imports() }
    }

    // MARK: - Private

    private func copy() -> SentinelScopeBuilder {
        SentinelScopeBuilder(
            path: basePath,
            folder: folder,
            includes: includePatterns,
            excludes: excludePatterns
        )
    }

    public static func resetCache() {
        sourceCodeCache.removeAll()
    }
}
