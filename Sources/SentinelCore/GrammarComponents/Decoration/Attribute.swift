import SwiftSyntax

public struct Attribute: DeclarationDecoration, Sendable {
    public let name: String
    public let annotation: Annotation?
    public let arguments: [Argument]

    public var description: String {
        if arguments.isEmpty {
            return "@\(name)"
        }
        let args = arguments.map(\.description).joined(separator: ", ")
        return "@\(name)(\(args))"
    }

    init(node: AttributeSyntax) {
        let attributeName: String
        if let identifierType = node.attributeName.as(IdentifierTypeSyntax.self) {
            attributeName = identifierType.name.text
        } else {
            attributeName = node.attributeName.description.removingLeadingTrailingWhitespace()
        }

        self.name = attributeName
        self.annotation = Annotation.from(name: attributeName)
        self.arguments = Attribute.extractArguments(from: node)
    }

    private static func extractArguments(from node: AttributeSyntax) -> [Argument] {
        guard let arguments = node.arguments else { return [] }

        switch arguments {
        case .argumentList(let list):
            return list.map {
                Argument(
                    label: $0.label?.text,
                    value: $0.expression.description.removingLeadingTrailingWhitespace()
                )
            }
        case .availability(let availability):
            return availability.map {
                Argument(label: nil, value: $0.description.removingLeadingTrailingWhitespace())
            }
        default:
            return [Argument(label: nil, value: arguments.description.removingLeadingTrailingWhitespace())]
        }
    }

    public static func attributes(from list: AttributeListSyntax) -> [Attribute] {
        list.compactMap { element in
            guard case .attribute(let attr) = element else { return nil }
            return Attribute(node: attr)
        }
    }
}
