import SwiftSyntax

public final class Variable: NamedDeclaration, AttributesProviding, ModifiersProviding,
                             TypeProviding, InitializerClauseProviding, AccessorBlocksProviding,
                             ParentDeclarationProviding, SourceCodeProviding,
                             SyntaxNodeProviding, @unchecked Sendable {
    public typealias SyntaxNode = PatternBindingSyntax

    public let node: PatternBindingSyntax
    public let name: String
    public let attributes: [Attribute]
    public let modifiers: [Modifier]
    public let typeAnnotation: TypeAnnotation?
    public let initializerClause: InitializerClause?
    public let accessors: [AccessorBlock]
    public let getter: GetterBlock?
    public let isConstant: Bool
    public let parent: Declaration?
    public let sourceCodeLocation: SourceCodeLocation

    public var isVariable: Bool { !isConstant }
    public var isOptional: Bool { typeAnnotation?.isOptional ?? false }

    public var isComputed: Bool {
        node.accessorBlock != nil && initializerClause == nil
    }

    public var isStored: Bool { !isComputed }

    public var isOfInferredType: Bool {
        typeAnnotation == nil
    }

    public var description: String {
        let keyword = isConstant ? "let" : "var"
        if let type = typeAnnotation {
            return "\(keyword) \(name): \(type.name)"
        }
        return "\(keyword) \(name)"
    }

    init(binding: PatternBindingSyntax, modifiers: [Modifier], attributes: [Attribute],
         isConstant: Bool, parent: Declaration?, sourceCodeLocation: SourceCodeLocation) {
        self.node = binding
        self.name = binding.pattern.description.removingLeadingTrailingWhitespace().removingBackticks()
        self.attributes = attributes
        self.modifiers = modifiers
        self.typeAnnotation = TypeAnnotation(typeAnnotation: binding.typeAnnotation)
        self.initializerClause = InitializerClause(clause: binding.initializer)
        self.accessors = AccessorBlock.accessors(from: binding.accessorBlock)
        self.getter = GetterBlock(from: binding.accessorBlock)
        self.isConstant = isConstant
        self.parent = parent
        self.sourceCodeLocation = sourceCodeLocation
    }
}
