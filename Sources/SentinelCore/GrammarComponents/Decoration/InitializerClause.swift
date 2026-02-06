import SwiftSyntax

public struct InitializerClause: DeclarationDecoration, Sendable {
    public let value: String
    public let isSelfReference: Bool

    public var description: String {
        value
    }

    init?(clause: InitializerClauseSyntax?) {
        guard let clause = clause else { return nil }
        let valueText = clause.value.description.removingLeadingTrailingWhitespace()
        self.value = valueText
        self.isSelfReference = valueText == "self"
    }
}
