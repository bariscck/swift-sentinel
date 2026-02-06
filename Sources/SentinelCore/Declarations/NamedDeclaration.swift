public protocol NamedDeclaration: Declaration {
    var name: String { get }
}

extension NamedDeclaration {
    public var description: String {
        name
    }
}
