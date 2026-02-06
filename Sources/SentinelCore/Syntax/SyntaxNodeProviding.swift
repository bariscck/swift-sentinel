import SwiftSyntax

public protocol SyntaxNodeProviding: Equatable, Hashable {
    associatedtype SyntaxNode: SyntaxProtocol
    var node: SyntaxNode { get }
}

extension SyntaxNodeProviding {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.node.id == rhs.node.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(node.id)
    }
}
