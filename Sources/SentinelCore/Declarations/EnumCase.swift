import SwiftSyntax

public final class EnumCase: NamedDeclaration, AttributesProviding, ModifiersProviding,
                             ParametersProviding, InitializerClauseProviding,
                             SourceCodeProviding, SyntaxNodeProviding, @unchecked Sendable {
    public typealias SyntaxNode = EnumCaseElementSyntax

    public let node: EnumCaseElementSyntax
    public let name: String
    public let attributes: [Attribute]
    public let modifiers: [Modifier]
    public let parameters: [Parameter]
    public let initializerClause: InitializerClause?
    public let sourceCodeLocation: SourceCodeLocation

    public var description: String {
        name
    }

    init(element: EnumCaseElementSyntax, caseDecl: EnumCaseDeclSyntax,
         parent: Declaration?, sourceCodeLocation: SourceCodeLocation) {
        self.node = element
        self.name = element.name.text.removingBackticks()
        self.attributes = Attribute.attributes(from: caseDecl.attributes)
        self.modifiers = Modifier.modifiers(from: caseDecl.modifiers)
        self.parameters = element.parameterClause?.parameters.map {
            Parameter(enumCaseParam: $0)
        } ?? []
        self.initializerClause = InitializerClause(clause: element.rawValue?.value != nil
            ? nil : nil)  // EnumCase raw values handled differently
        self.sourceCodeLocation = sourceCodeLocation
    }

    static func cases(from caseDecl: EnumCaseDeclSyntax, parent: Declaration?,
                      sourceCodeLocation: SourceCodeLocation) -> [EnumCase] {
        caseDecl.elements.map {
            EnumCase(element: $0, caseDecl: caseDecl, parent: parent,
                     sourceCodeLocation: sourceCodeLocation)
        }
    }
}
