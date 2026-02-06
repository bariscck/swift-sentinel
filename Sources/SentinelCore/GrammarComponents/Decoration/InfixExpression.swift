import SwiftSyntax

public struct InfixExpression: DeclarationDecoration, Sendable {
    public let leftOperand: String
    public let `operator`: String
    public let rightOperand: String

    public var description: String {
        "\(leftOperand) \(`operator`) \(rightOperand)"
    }

    init?(expression: InfixOperatorExprSyntax) {
        self.leftOperand = expression.leftOperand.description.removingLeadingTrailingWhitespace()
        self.operator = expression.operator.description.removingLeadingTrailingWhitespace()
        self.rightOperand = expression.rightOperand.description.removingLeadingTrailingWhitespace()
    }
}
