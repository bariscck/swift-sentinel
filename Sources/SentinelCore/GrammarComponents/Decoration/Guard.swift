import SwiftSyntax

public struct Guard: DeclarationDecoration, Sendable {
    public let conditions: [Condition]
    public let body: Body?

    public var description: String {
        "guard"
    }

    init(statement: GuardStmtSyntax) {
        self.conditions = Condition.conditions(from: statement.conditions)
        self.body = Body(codeBlock: statement.body.statements)
    }

    static func guards(from items: CodeBlockItemListSyntax) -> [Guard] {
        items.compactMap { item in
            if let guardStmt = item.item.as(GuardStmtSyntax.self) {
                return Guard(statement: guardStmt)
            }
            return nil
        }
    }
}
