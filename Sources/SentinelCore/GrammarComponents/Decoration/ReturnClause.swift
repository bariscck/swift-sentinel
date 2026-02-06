import SwiftSyntax

public struct ReturnClause: DeclarationDecoration, Sendable {
    public let typeName: String

    public var description: String {
        typeName
    }

    init?(clause: ReturnClauseSyntax?) {
        guard let clause = clause else { return nil }
        self.typeName = clause.type.description.removingLeadingTrailingWhitespace()
    }
}
