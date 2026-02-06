import SwiftSyntax

public struct Closure: DeclarationDecoration, Sendable {
    public let parameters: [String]
    public let captures: [Capture]
    public let returnType: ReturnClause?
    public let body: Body?
    public let hasAnySelfReference: Bool

    public var description: String {
        "closure"
    }

    init(node: ClosureExprSyntax) {
        let sig = node.signature

        self.parameters = sig?.parameterClause.map { clause -> [String] in
            switch clause {
            case .simpleInput(let params):
                return params.map { $0.name.text }
            case .parameterClause(let params):
                return params.parameters.map { $0.firstName.text }
            }
        } ?? []

        self.captures = sig?.capture?.items.map { Capture(item: $0) } ?? []
        self.returnType = sig?.returnClause.flatMap { ReturnClause(clause: $0) }

        let bodyNode = Body(codeBlock: node.statements)
        self.body = bodyNode

        let statementsText = node.statements.description
        self.hasAnySelfReference = statementsText.contains("self.")
            || statementsText.contains("self[")
            || statementsText.range(of: "\\bself\\b", options: .regularExpression) != nil
    }

    public static func closures(from items: CodeBlockItemListSyntax) -> [Closure] {
        items.compactMap { item in
            if let closureExpr = item.item.as(ClosureExprSyntax.self) {
                return Closure(node: closureExpr)
            }
            return nil
        }
    }
}
