import Foundation
import SwiftSyntax
import SwiftParser

/// Discovers Rule-conforming type names from Swift source files using SwiftSyntax.
struct RuleDiscovery {

    /// Discover all struct/class names that conform to `Rule` in the given Swift files.
    static func discoverRuleTypes(in files: [URL]) -> [String] {
        files.flatMap { discoverRuleTypes(in: $0) }
    }

    /// Discover Rule-conforming type names in a single file.
    static func discoverRuleTypes(in fileURL: URL) -> [String] {
        guard let source = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return []
        }
        return discoverRuleTypes(in: source)
    }

    /// Discover Rule-conforming type names from a source string.
    static func discoverRuleTypes(in source: String) -> [String] {
        let tree = Parser.parse(source: source)
        let visitor = RuleConformanceVisitor(viewMode: .sourceAccurate)
        visitor.walk(tree)
        return visitor.ruleTypeNames
    }
}

/// SyntaxVisitor that finds struct/class declarations conforming to `Rule`.
private final class RuleConformanceVisitor: SyntaxVisitor {
    var ruleTypeNames: [String] = []

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if conformsToRule(node.inheritanceClause) {
            ruleTypeNames.append(node.name.text)
        }
        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if conformsToRule(node.inheritanceClause) {
            ruleTypeNames.append(node.name.text)
        }
        return .skipChildren
    }

    private func conformsToRule(_ clause: InheritanceClauseSyntax?) -> Bool {
        guard let clause else { return false }
        return clause.inheritedTypes.contains { inherited in
            inherited.type.trimmedDescription == "Rule"
        }
    }
}
