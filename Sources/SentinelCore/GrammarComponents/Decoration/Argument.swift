public struct Argument: DeclarationDecoration, Sendable {
    public let label: String?
    public let value: String

    public var description: String {
        if let label = label {
            return "\(label): \(value)"
        }
        return value
    }
}
