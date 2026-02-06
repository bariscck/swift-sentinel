import SwiftSyntax

public final class Class: NamedDeclaration, AttributesProviding, ModifiersProviding,
                          InheritanceProviding, DeclarationsProviding, ParentDeclarationProviding,
                          SourceCodeProviding, SyntaxNodeProviding, @unchecked Sendable {
    public typealias SyntaxNode = ClassDeclSyntax

    public let node: ClassDeclSyntax
    public let name: String
    public let attributes: [Attribute]
    public let modifiers: [Modifier]
    public let inheritanceTypesNames: [String]
    public let parent: Declaration?
    public let sourceCodeLocation: SourceCodeLocation

    public var declarations: [Declaration] {
        DeclarationsCache.shared.declarations(from: node)
    }

    init(node: ClassDeclSyntax, parent: Declaration?, sourceCodeLocation: SourceCodeLocation) {
        self.node = node
        self.name = node.name.text.removingBackticks()
        self.attributes = Attribute.attributes(from: node.attributes)
        self.modifiers = Modifier.modifiers(from: node.modifiers)
        self.inheritanceTypesNames = node.inheritanceClause?.inheritedTypes.map {
            $0.type.description.removingLeadingTrailingWhitespace()
        } ?? []
        self.parent = parent
        self.sourceCodeLocation = sourceCodeLocation
    }
}
