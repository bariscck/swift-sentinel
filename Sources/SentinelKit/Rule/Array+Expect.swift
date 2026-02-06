import SentinelCore
import SwiftSyntax

extension Array where Element: SourceCodeProviding & NamedDeclaration & SyntaxNodeProviding {
    /// Returns violations for elements where the predicate returns false.
    public func expect(
        identifier: String,
        message: String,
        severity: Severity,
        _ predicate: (Element) -> Bool
    ) -> [Violation] {
        compactMap { element in
            guard !predicate(element) else { return nil }
            let location = element.sourceCodeLocation
            let pos = location.position(of: element.node)
            return Violation(
                ruleIdentifier: identifier,
                message: message,
                severity: severity,
                filePath: location.filePath,
                line: pos.line,
                column: pos.column
            )
        }
    }
}
