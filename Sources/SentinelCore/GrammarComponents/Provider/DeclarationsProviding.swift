public protocol DeclarationsProviding: Declaration {
    var declarations: [Declaration] { get }
}

extension DeclarationsProviding {
    public func classes() -> [Class] {
        declarations.compactMap { $0 as? Class }
    }

    public func structs() -> [Struct] {
        declarations.compactMap { $0 as? Struct }
    }

    public func enums() -> [Enum] {
        declarations.compactMap { $0 as? Enum }
    }

    public func protocols() -> [ProtocolDeclaration] {
        declarations.compactMap { $0 as? ProtocolDeclaration }
    }

    public func functions() -> [Function] {
        declarations.compactMap { $0 as? Function }
    }

    public func variables() -> [Variable] {
        declarations.compactMap { $0 as? Variable }
    }

    public func initializers() -> [Initializer] {
        declarations.compactMap { $0 as? Initializer }
    }
}
