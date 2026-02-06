import SwiftSyntax

public struct Condition: DeclarationDecoration, Sendable {
    public let content: String

    public var description: String {
        content
    }

    init(condition: ConditionElementSyntax) {
        self.content = condition.description.removingLeadingTrailingWhitespace()
    }

    public static func conditions(from list: ConditionElementListSyntax) -> [Condition] {
        list.map { Condition(condition: $0) }
    }
}
