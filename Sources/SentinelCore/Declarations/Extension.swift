import SwiftSyntax

public final class Extension: Declaration, AttributesProviding, ModifiersProviding,
                              InheritanceProviding, DeclarationsProviding,
                              SourceCodeProviding, SyntaxNodeProviding, @unchecked Sendable {
    public typealias SyntaxNode = ExtensionDeclSyntax

    public let node: ExtensionDeclSyntax
    public let typeAnnotation: TypeAnnotation
    public let attributes: [Attribute]
    public let modifiers: [Modifier]
    public let inheritanceTypesNames: [String]
    public let sourceCodeLocation: SourceCodeLocation

    public var declarations: [Declaration] {
        DeclarationsCache.shared.declarations(from: node)
    }

    public var description: String {
        "extension \(typeAnnotation.name)"
    }

    init(node: ExtensionDeclSyntax, parent: Declaration?, sourceCodeLocation: SourceCodeLocation) {
        self.node = node
        self.typeAnnotation = TypeAnnotation(type: node.extendedType)
        self.attributes = Attribute.attributes(from: node.attributes)
        self.modifiers = Modifier.modifiers(from: node.modifiers)
        self.inheritanceTypesNames = node.inheritanceClause?.inheritedTypes.map {
            $0.type.description.removingLeadingTrailingWhitespace()
        } ?? []
        self.sourceCodeLocation = sourceCodeLocation
    }
}
