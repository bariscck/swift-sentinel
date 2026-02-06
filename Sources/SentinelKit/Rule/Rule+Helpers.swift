import SentinelCore
import SwiftSyntax

extension Rule {
    /// Creates a violation for a specific named declaration.
    public func violation<T: SourceCodeProviding & NamedDeclaration & SyntaxNodeProviding>(
        on declaration: T,
        message: String? = nil
    ) -> Violation {
        let location = declaration.sourceCodeLocation
        let pos = location.position(of: declaration.node)
        return Violation(
            ruleIdentifier: identifier,
            message: message ?? ruleDescription,
            severity: severity,
            filePath: location.filePath,
            line: pos.line,
            column: pos.column
        )
    }

    /// Shorthand expect: returns violations for declarations failing the predicate.
    public func expect<T: SourceCodeProviding & NamedDeclaration & SyntaxNodeProviding>(
        _ declarations: [T],
        message: String? = nil,
        _ predicate: (T) -> Bool
    ) -> [Violation] {
        declarations.compactMap { declaration in
            guard !predicate(declaration) else { return nil }
            return violation(on: declaration, message: message)
        }
    }
}
