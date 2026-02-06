import SwiftSyntax

public struct Body: DeclarationDecoration, Sendable {
    public let content: String
    public let statements: [Statement]
    public let variables: [Variable]
    public let functionCalls: [FunctionCall]
    public let ifs: [If]
    public let switches: [Switch]
    public let guards: [Guard]
    public let infixExpressions: [InfixExpression]
    public let closures: [Closure]
    public let hasAnySelfReference: Bool
    public let hasAnyClosureWithSelfReference: Bool

    public var description: String {
        content
    }

    init(codeBlock: CodeBlockItemListSyntax) {
        self.content = codeBlock.description

        self.statements = codeBlock.map { Statement(item: $0) }

        // Extract variables from variable declarations
        var vars: [Variable] = []
        for item in codeBlock {
            if let varDecl = item.item.as(VariableDeclSyntax.self) {
                for binding in varDecl.bindings {
                    vars.append(Variable(
                        binding: binding,
                        modifiers: Modifier.modifiers(from: varDecl.modifiers),
                        attributes: Attribute.attributes(from: varDecl.attributes),
                        isConstant: varDecl.bindingSpecifier.text == "let",
                        parent: nil,
                        sourceCodeLocation: SourceCodeLocation(sourceFilePath: nil, sourceFileTree: codeBlock)
                    ))
                }
            }
        }
        self.variables = vars

        self.functionCalls = FunctionCall.functionCalls(from: codeBlock)
        self.ifs = If.ifs(from: codeBlock)
        self.switches = Switch.switches(from: codeBlock)
        self.guards = Guard.guards(from: codeBlock)
        self.closures = Closure.closures(from: codeBlock)

        // Extract infix expressions
        self.infixExpressions = codeBlock.compactMap { item in
            if let infixExpr = item.item.as(InfixOperatorExprSyntax.self) {
                return InfixExpression(expression: infixExpr)
            }
            return nil
        }

        let text = codeBlock.description
        self.hasAnySelfReference = text.contains("self.") || text.contains("self[")
        self.hasAnyClosureWithSelfReference = closures.contains { $0.hasAnySelfReference }
    }
}
