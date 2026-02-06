import Foundation
import SwiftSyntax
import SwiftParser

public final class SwiftSourceCode: @unchecked Sendable {
    nonisolated(unsafe) private static var cache = ConcurrentDictionary<String, SwiftSourceCode>()

    public let source: String
    public let url: URL?
    public let id: UUID

    private lazy var resolved: (tree: SourceFileSyntax, collector: DeclarationsCollector) = {
        SourceFileSyntaxResolver(source: source, url: url).resolve()
    }()

    public var fileName: String? {
        url?.lastPathComponent
    }

    public var filePath: String? {
        url?.path
    }

    public init?(url: URL) {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            return nil
        }
        self.source = content
        self.url = url
        self.id = UUID()
    }

    public init(source: String) {
        self.source = source
        self.url = nil
        self.id = UUID()
    }

    // MARK: - Cached Factory

    public static func from(url: URL) -> SwiftSourceCode? {
        let key = url.path
        if let cached = cache[key] {
            return cached
        }
        guard let sourceCode = SwiftSourceCode(url: url) else { return nil }
        cache[key] = sourceCode
        return sourceCode
    }

    public static func from(source: String) -> SwiftSourceCode {
        let key = source.hashValue.description
        if let cached = cache[key] {
            return cached
        }
        let sourceCode = SwiftSourceCode(source: source)
        cache[key] = sourceCode
        return sourceCode
    }

    public static func resetCache() {
        cache.removeAll()
    }

    // MARK: - Declarations Access

    public func classes(includeNested: Bool = false) -> [Class] {
        includeNested ? resolved.collector.classes : resolved.collector.classes.filter { $0.parent == nil }
    }

    public func structs(includeNested: Bool = false) -> [Struct] {
        includeNested ? resolved.collector.structs : resolved.collector.structs.filter { $0.parent == nil }
    }

    public func enums(includeNested: Bool = false) -> [Enum] {
        includeNested ? resolved.collector.enums : resolved.collector.enums.filter { $0.parent == nil }
    }

    public func protocols(includeNested: Bool = false) -> [ProtocolDeclaration] {
        includeNested ? resolved.collector.protocols : resolved.collector.protocols.filter { $0 is ParentDeclarationProviding ? ($0 as! ParentDeclarationProviding).parent == nil : true }
    }

    public func functions(includeNested: Bool = false) -> [Function] {
        includeNested ? resolved.collector.functions : resolved.collector.functions.filter { $0.parent == nil }
    }

    public func variables(includeNested: Bool = false) -> [Variable] {
        includeNested ? resolved.collector.variables : resolved.collector.variables.filter { $0.parent == nil }
    }

    public func initializers(includeNested: Bool = false) -> [Initializer] {
        includeNested ? resolved.collector.initializers : resolved.collector.initializers.filter { $0.parent == nil }
    }

    public func extensions() -> [Extension] {
        resolved.collector.extensions
    }

    public func imports() -> [Import] {
        resolved.collector.imports
    }
}
