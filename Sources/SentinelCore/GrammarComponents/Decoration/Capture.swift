import SwiftSyntax

public struct Capture: DeclarationDecoration, Sendable {
    public enum Specifier: String, Sendable {
        case weak
        case unowned
    }

    public let name: String
    public let specifier: Specifier?

    public var description: String {
        if let specifier = specifier {
            return "\(specifier.rawValue) \(name)"
        }
        return name
    }

    init(item: ClosureCaptureSyntax) {
        if let initializer = item.initializer {
            self.name = initializer.value.description.removingLeadingTrailingWhitespace()
        } else {
            self.name = item.name.text
        }
        if let specifier = item.specifier?.specifier.text {
            self.specifier = Specifier(rawValue: specifier)
        } else {
            self.specifier = nil
        }
    }
}
