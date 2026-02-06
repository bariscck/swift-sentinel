import SwiftSyntax

public final class Function: NamedDeclaration, AttributesProviding, ModifiersProviding,
                             BodyProviding, DeclarationsProviding, ParametersProviding,
                             ReturnProviding, ParentDeclarationProviding,
                             SourceCodeProviding, SyntaxNodeProviding, @unchecked Sendable {
    public typealias SyntaxNode = FunctionDeclSyntax

    public let node: FunctionDeclSyntax
    public let name: String
    public let attributes: [Attribute]
    public let modifiers: [Modifier]
    public let parameters: [Parameter]
    public let returnClause: ReturnClause?
    public let body: Body?
    public let parent: Declaration?
    public let sourceCodeLocation: SourceCodeLocation

    public var declarations: [Declaration] {
        DeclarationsCache.shared.declarations(from: node)
    }

    init(node: FunctionDeclSyntax, parent: Declaration?, sourceCodeLocation: SourceCodeLocation) {
        self.node = node
        self.name = node.name.text.removingBackticks()
        self.attributes = Attribute.attributes(from: node.attributes)
        self.modifiers = Modifier.modifiers(from: node.modifiers)
        self.parameters = node.signature.parameterClause.parameters.map {
            Parameter(functionParam: $0)
        }
        self.returnClause = ReturnClause(clause: node.signature.returnClause)
        self.body = node.body.map { Body(codeBlock: $0.statements) }
        self.parent = parent
        self.sourceCodeLocation = sourceCodeLocation
    }
}
