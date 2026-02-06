/// Protocol defining the scope in which source code declarations are available for analysis.
public protocol SentinelScope: Sendable {
    func classes(includeNested: Bool) -> [Class]
    func structs(includeNested: Bool) -> [Struct]
    func enums(includeNested: Bool) -> [Enum]
    func protocols(includeNested: Bool) -> [ProtocolDeclaration]
    func functions(includeNested: Bool) -> [Function]
    func variables(includeNested: Bool) -> [Variable]
    func initializers(includeNested: Bool) -> [Initializer]
    func extensions() -> [Extension]
    func imports() -> [Import]
    var sourceCode: [SwiftSourceCode] { get }
}

extension SentinelScope {
    public func classes() -> [Class] { classes(includeNested: false) }
    public func structs() -> [Struct] { structs(includeNested: false) }
    public func enums() -> [Enum] { enums(includeNested: false) }
    public func protocols() -> [ProtocolDeclaration] { protocols(includeNested: false) }
    public func functions() -> [Function] { functions(includeNested: false) }
    public func variables() -> [Variable] { variables(includeNested: false) }
    public func initializers() -> [Initializer] { initializers(includeNested: false) }
}
