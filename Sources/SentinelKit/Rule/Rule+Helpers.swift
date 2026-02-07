import SentinelCore
import SwiftSyntax

extension Rule {
    /// Creates a violation for a specific named declaration.
    public func violation<T: SourceCodeProviding & NamedDeclaration & SyntaxNodeProviding>(
        on declaration: T,
        message: String
    ) -> Violation {
        let location = declaration.sourceCodeLocation
        let pos = location.position(of: declaration.node)
        return Violation(
            ruleIdentifier: identifier,
            message: message,
            severity: severity,
            filePath: location.filePath,
            line: pos.line,
            column: pos.column
        )
    }

    /// Shorthand expect: returns violations for declarations failing the predicate.
    public func expect<T: SourceCodeProviding & NamedDeclaration & SyntaxNodeProviding>(
        _ message: String,
        for declarations: [T],
        _ predicate: (T) -> Bool
    ) -> [Violation] {
        declarations.compactMap { declaration in
            guard !predicate(declaration) else { return nil }
            return violation(on: declaration, message: message)
        }
    }
}
