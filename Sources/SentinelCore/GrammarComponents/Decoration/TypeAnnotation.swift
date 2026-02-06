import SwiftSyntax

public struct TypeAnnotation: DeclarationDecoration, Sendable {
    public let name: String
    public let isOptional: Bool

    public var description: String {
        name
    }

    public var annotation: String {
        if isOptional {
            return "Optional<\(name.dropLast())>"
        }
        return name
    }

    init(type: TypeSyntax) {
        let isOpt = type.is(OptionalTypeSyntax.self) || type.is(ImplicitlyUnwrappedOptionalTypeSyntax.self)
        self.isOptional = isOpt
        self.name = type.description.removingLeadingTrailingWhitespace()
    }

    init?(type: TypeSyntax?) {
        guard let type = type else { return nil }
        self.init(type: type)
    }

    init?(typeAnnotation: TypeAnnotationSyntax?) {
        guard let typeAnnotation = typeAnnotation else { return nil }
        self.init(type: typeAnnotation.type)
    }
}
