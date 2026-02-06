import SwiftSyntax

public struct Switch: DeclarationDecoration, Sendable {
    public let expression: String
    public let cases: [String]

    public var description: String {
        "switch"
    }

    init(expression switchExpr: SwitchExprSyntax) {
        self.expression = switchExpr.subject.description.removingLeadingTrailingWhitespace()
        self.cases = switchExpr.cases.map { $0.description.removingLeadingTrailingWhitespace() }
    }

    static func switches(from items: CodeBlockItemListSyntax) -> [Switch] {
        items.compactMap { item in
            if let switchExpr = item.item.as(SwitchExprSyntax.self) {
                return Switch(expression: switchExpr)
            }
            return nil
        }
    }
}
