import SwiftSyntax

public struct FunctionCall: DeclarationDecoration, Sendable {
    public let call: String
    public let arguments: [Argument]
    public let closure: Closure?
    public let additionalClosures: [Closure]
    public let inlineCalls: [FunctionCall]

    public var description: String {
        call
    }

    init(expression: FunctionCallExprSyntax) {
        self.call = expression.calledExpression.description.removingLeadingTrailingWhitespace()
        self.arguments = expression.arguments.map {
            Argument(
                label: $0.label?.text,
                value: $0.expression.description.removingLeadingTrailingWhitespace()
            )
        }
        self.closure = expression.trailingClosure.map { Closure(node: $0) }
        self.additionalClosures = expression.additionalTrailingClosures.map {
            Closure(node: $0.closure)
        }

        var inline: [FunctionCall] = []
        if let memberAccess = expression.calledExpression.as(MemberAccessExprSyntax.self),
           let base = memberAccess.base?.as(FunctionCallExprSyntax.self) {
            inline.append(FunctionCall(expression: base))
        }
        self.inlineCalls = inline
    }

    public func tokens(startingWith prefix: String) -> [String] {
        call.split(separator: ".").map(String.init).filter { $0.hasPrefix(prefix) }
    }

    static func functionCalls(from items: CodeBlockItemListSyntax) -> [FunctionCall] {
        items.compactMap { item in
            if let funcCall = item.item.as(FunctionCallExprSyntax.self) {
                return FunctionCall(expression: funcCall)
            }
            return nil
        }
    }
}
