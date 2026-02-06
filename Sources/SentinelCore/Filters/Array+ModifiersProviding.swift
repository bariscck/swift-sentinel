extension Array where Element: ModifiersProviding {
    public func withModifiers(_ predicate: ([Modifier]) -> Bool) -> [Element] {
        filter { predicate($0.modifiers) }
    }

    public func withModifier(_ modifier: Modifier) -> [Element] {
        filter { $0.hasModifier(modifier) }
    }

    public func withoutModifier(_ modifier: Modifier) -> [Element] {
        filter { !$0.hasModifier(modifier) }
    }

    public func withPublicModifier() -> [Element] {
        withModifier(.public)
    }

    public func withPrivateModifier() -> [Element] {
        withModifier(.private)
    }

    public func withInternalModifier() -> [Element] {
        withModifier(.internal)
    }

    public func withOpenModifier() -> [Element] {
        withModifier(.open)
    }

    public func withStaticModifier() -> [Element] {
        withModifier(.static)
    }

    public func withFinalModifier() -> [Element] {
        withModifier(.final)
    }

    public func withOverrideModifier() -> [Element] {
        withModifier(.override)
    }

    public func withLazyModifier() -> [Element] {
        withModifier(.lazy)
    }

    public func withWeakModifier() -> [Element] {
        withModifier(.weak)
    }

    public func withModifiersCount(_ count: Int) -> [Element] {
        filter { $0.modifiers.count == count }
    }
}
