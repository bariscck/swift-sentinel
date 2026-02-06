import Foundation
import SwiftSyntax

public final class DeclarationsCache: @unchecked Sendable {
    public static let shared = DeclarationsCache()

    private var nodesAndDeclarations: [SyntaxIdentifier: [Declaration]] = [:]
    private var typeInheritanceCache: [String: [String]] = [:]
    private let lock = NSLock()

    private init() {}

    public func declarations<T: SyntaxProtocol>(from node: T) -> [Declaration] {
        lock.lock()
        defer { lock.unlock() }
        return nodesAndDeclarations[node.id] ?? []
    }

    public func put<T: SyntaxProtocol>(children: [Declaration], for node: T) {
        lock.lock()
        defer { lock.unlock() }
        let existing = nodesAndDeclarations[node.id] ?? []
        nodesAndDeclarations[node.id] = existing + children
    }

    public func inheritedTypes(of typeName: String) -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return typeInheritanceCache[typeName] ?? []
    }

    public func put(subtype: String, of supertype: String) {
        lock.lock()
        defer { lock.unlock() }
        var types = typeInheritanceCache[supertype] ?? []
        if !types.contains(subtype) {
            types.append(subtype)
        }
        typeInheritanceCache[supertype] = types
    }

    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        nodesAndDeclarations.removeAll()
        typeInheritanceCache.removeAll()
    }
}
