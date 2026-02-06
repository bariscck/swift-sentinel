import SwiftSyntax

public final class Import: NamedDeclaration, AttributesProviding, SourceCodeProviding,
                           SyntaxNodeProviding, @unchecked Sendable {
    public typealias SyntaxNode = ImportDeclSyntax

    public enum Kind: String, Sendable {
        case `typealias`
        case `struct`
        case `class`
        case `enum`
        case `protocol`
        case `let`
        case `var`
        case `func`
        case module
    }

    public let node: ImportDeclSyntax
    public let name: String
    public let kind: Kind
    public let attributes: [Attribute]
    public let sourceCodeLocation: SourceCodeLocation

    public var description: String {
        "import \(name)"
    }

    init(node: ImportDeclSyntax, sourceCodeLocation: SourceCodeLocation) {
        self.node = node
        self.name = node.path.map { $0.name.text }.joined(separator: ".")
        self.kind = node.importKindSpecifier.flatMap { Kind(rawValue: $0.text) } ?? .module
        self.attributes = Attribute.attributes(from: node.attributes)
        self.sourceCodeLocation = sourceCodeLocation
    }
}
