import SwiftSyntax

public struct Statement: DeclarationDecoration, Sendable {
    public let content: String

    public var description: String {
        content
    }

    init(item: CodeBlockItemSyntax) {
        self.content = item.description.removingLeadingTrailingWhitespace()
    }
}
