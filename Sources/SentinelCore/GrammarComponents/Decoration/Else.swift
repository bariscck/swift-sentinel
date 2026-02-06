public indirect enum Else: DeclarationDecoration, Sendable {
    case elseBlock(body: Body?)
    case elseIf(If)

    public var body: Body? {
        switch self {
        case .elseBlock(let body): return body
        case .elseIf(let ifNode): return ifNode.body
        }
    }

    public var description: String {
        "else"
    }
}
