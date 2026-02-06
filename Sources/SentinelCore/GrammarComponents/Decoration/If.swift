import SwiftSyntax

public indirect enum If: DeclarationDecoration, Sendable {
    case node(conditions: [Condition], body: Body?, elseClause: Else?)

    public var conditions: [Condition] {
        switch self { case .node(let c, _, _): return c }
    }

    public var body: Body? {
        switch self { case .node(_, let b, _): return b }
    }

    public var elseClause: Else? {
        switch self { case .node(_, _, let e): return e }
    }

    public var description: String {
        "if"
    }

    init(expression: IfExprSyntax) {
        let conditions = Condition.conditions(from: expression.conditions)
        let body = Body(codeBlock: expression.body.statements)
        let elseClause: Else?
        if let elseBody = expression.elseBody {
            switch elseBody {
            case .ifExpr(let elseIf):
                elseClause = .elseIf(If(expression: elseIf))
            case .codeBlock(let block):
                elseClause = .elseBlock(body: Body(codeBlock: block.statements))
            }
        } else {
            elseClause = nil
        }
        self = .node(conditions: conditions, body: body, elseClause: elseClause)
    }

    static func ifs(from items: CodeBlockItemListSyntax) -> [If] {
        items.compactMap { item in
            if let ifExpr = item.item.as(IfExprSyntax.self) {
                return If(expression: ifExpr)
            }
            return nil
        }
    }
}
