public protocol ModifiersProviding: Declaration {
    var modifiers: [Modifier] { get }
}

extension ModifiersProviding {
    public func hasModifier(_ modifier: Modifier) -> Bool {
        modifiers.contains(modifier)
    }

    public var isPublic: Bool { hasModifier(.public) }
    public var isPrivate: Bool { hasModifier(.private) }
    public var isInternal: Bool { hasModifier(.internal) }
    public var isFilePrivate: Bool { hasModifier(.fileprivate) }
    public var isOpen: Bool { hasModifier(.open) }
    public var isStatic: Bool { hasModifier(.static) }
    public var isFinal: Bool { hasModifier(.final) }
    public var isOverride: Bool { hasModifier(.override) }
    public var isLazy: Bool { hasModifier(.lazy) }
    public var isWeak: Bool { hasModifier(.weak) }
}
