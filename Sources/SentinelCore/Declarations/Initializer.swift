import SwiftSyntax

public final class Initializer: Declaration, AttributesProviding, ModifiersProviding,
                                BodyProviding, ParametersProviding, ParentDeclarationProviding,
                                SourceCodeProviding, SyntaxNodeProviding, @unchecked Sendable {
    public typealias SyntaxNode = InitializerDeclSyntax

    public let node: InitializerDeclSyntax
    public let attributes: [Attribute]
    public let modifiers: [Modifier]
    public let parameters: [Parameter]
    public let body: Body?
    public let isFailable: Bool
    public let parent: Declaration?
    public let sourceCodeLocation: SourceCodeLocation

    public var description: String {
        let params = parameters.map(\.description).joined(separator: ", ")
        let failable = isFailable ? "?" : ""
        return "init\(failable)(\(params))"
    }

    init(node: InitializerDeclSyntax, parent: Declaration?, sourceCodeLocation: SourceCodeLocation) {
        self.node = node
        self.attributes = Attribute.attributes(from: node.attributes)
        self.modifiers = Modifier.modifiers(from: node.modifiers)
        self.parameters = node.signature.parameterClause.parameters.map {
            Parameter(functionParam: $0)
        }
        self.body = node.body.map { Body(codeBlock: $0.statements) }
        self.isFailable = node.optionalMark != nil
        self.parent = parent
        self.sourceCodeLocation = sourceCodeLocation
    }
}
