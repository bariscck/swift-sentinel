import Foundation
import SwiftSyntax

/// Walks the Swift syntax tree and collects all declarations into categorized arrays.
public final class DeclarationsCollector: SyntaxVisitor {
    public private(set) var declarations: [Declaration] = []
    public private(set) var rootDeclarations: [Declaration] = []

    public private(set) var classes: [Class] = []
    public private(set) var structs: [Struct] = []
    public private(set) var enums: [Enum] = []
    public private(set) var protocols: [ProtocolDeclaration] = []
    public private(set) var functions: [Function] = []
    public private(set) var variables: [Variable] = []
    public private(set) var initializers: [Initializer] = []
    public private(set) var extensions: [Extension] = []
    public private(set) var imports: [Import] = []
    public private(set) var enumCases: [EnumCase] = []

    private var parentStack: [Declaration] = []
    private let sourceCodeLocation: SourceCodeLocation

    public init(sourceCodeLocation: SourceCodeLocation) {
        self.sourceCodeLocation = sourceCodeLocation
        super.init(viewMode: .sourceAccurate)
    }

    private var currentParent: Declaration? {
        parentStack.last
    }

    private func startScope(with declaration: Declaration) {
        parentStack.append(declaration)
    }

    private func endScope() {
        parentStack.removeLast()
    }

    private func register(_ declaration: Declaration) {
        declarations.append(declaration)
        if parentStack.isEmpty {
            rootDeclarations.append(declaration)
        }
        if let parent = currentParent {
            if let parentNode = (parent as? any SyntaxNodeProviding) {
                let node = parentNode.node as any SyntaxProtocol
                DeclarationsCache.shared.put(children: [declaration], for: node)
            }
        }
    }

    // MARK: - Classes

    override public func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        let decl = Class(node: node, parent: currentParent, sourceCodeLocation: sourceCodeLocation)
        classes.append(decl)
        register(decl)
        startScope(with: decl)
        cacheInheritance(typeName: decl.name, inheriting: decl.inheritanceTypesNames)
        return .visitChildren
    }

    override public func visitPost(_ node: ClassDeclSyntax) {
        endScope()
    }

    // MARK: - Structs

    override public func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let decl = Struct(node: node, parent: currentParent, sourceCodeLocation: sourceCodeLocation)
        structs.append(decl)
        register(decl)
        startScope(with: decl)
        cacheInheritance(typeName: decl.name, inheriting: decl.inheritanceTypesNames)
        return .visitChildren
    }

    override public func visitPost(_ node: StructDeclSyntax) {
        endScope()
    }

    // MARK: - Enums

    override public func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        let decl = Enum(node: node, parent: currentParent, sourceCodeLocation: sourceCodeLocation)
        enums.append(decl)
        register(decl)
        startScope(with: decl)
        cacheInheritance(typeName: decl.name, inheriting: decl.inheritanceTypesNames)
        return .visitChildren
    }

    override public func visitPost(_ node: EnumDeclSyntax) {
        endScope()
    }

    // MARK: - Protocols

    override public func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        let decl = ProtocolDeclaration(node: node, parent: currentParent, sourceCodeLocation: sourceCodeLocation)
        protocols.append(decl)
        register(decl)
        startScope(with: decl)
        return .visitChildren
    }

    override public func visitPost(_ node: ProtocolDeclSyntax) {
        endScope()
    }

    // MARK: - Functions

    override public func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let decl = Function(node: node, parent: currentParent, sourceCodeLocation: sourceCodeLocation)
        functions.append(decl)
        register(decl)
        startScope(with: decl)
        return .visitChildren
    }

    override public func visitPost(_ node: FunctionDeclSyntax) {
        endScope()
    }

    // MARK: - Variables

    override public func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        let attrs = Attribute.attributes(from: node.attributes)
        let mods = Modifier.modifiers(from: node.modifiers)
        let isConstant = node.bindingSpecifier.text == "let"

        for binding in node.bindings {
            let decl = Variable(
                binding: binding,
                modifiers: mods,
                attributes: attrs,
                isConstant: isConstant,
                parent: currentParent,
                sourceCodeLocation: sourceCodeLocation
            )
            variables.append(decl)
            register(decl)
        }
        return .skipChildren
    }

    // MARK: - Initializers

    override public func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        let decl = Initializer(node: node, parent: currentParent, sourceCodeLocation: sourceCodeLocation)
        initializers.append(decl)
        register(decl)
        startScope(with: decl)
        return .visitChildren
    }

    override public func visitPost(_ node: InitializerDeclSyntax) {
        endScope()
    }

    // MARK: - Extensions

    override public func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        let decl = Extension(node: node, parent: currentParent, sourceCodeLocation: sourceCodeLocation)
        extensions.append(decl)
        register(decl)
        startScope(with: decl)
        return .visitChildren
    }

    override public func visitPost(_ node: ExtensionDeclSyntax) {
        endScope()
    }

    // MARK: - Imports

    override public func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        let decl = Import(node: node, sourceCodeLocation: sourceCodeLocation)
        imports.append(decl)
        register(decl)
        return .skipChildren
    }

    // MARK: - Enum Cases

    override public func visit(_ node: EnumCaseDeclSyntax) -> SyntaxVisitorContinueKind {
        let cases = EnumCase.cases(from: node, parent: currentParent,
                                   sourceCodeLocation: sourceCodeLocation)
        for c in cases {
            enumCases.append(c)
            register(c)
        }
        return .skipChildren
    }

    // MARK: - Inheritance Cache

    private func cacheInheritance(typeName: String, inheriting: [String]) {
        for parentType in inheriting {
            DeclarationsCache.shared.put(subtype: typeName, of: parentType)
        }
    }
}
