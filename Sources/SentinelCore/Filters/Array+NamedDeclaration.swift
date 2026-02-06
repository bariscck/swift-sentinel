extension Array where Element: NamedDeclaration {
    public func withName(_ predicate: (String) -> Bool) -> [Element] {
        filter { predicate($0.name) }
    }

    public func withName(_ name: String) -> [Element] {
        filter { $0.name == name }
    }

    public func withName(_ names: [String]) -> [Element] {
        filter { names.contains($0.name) }
    }

    public func withoutName(_ name: String) -> [Element] {
        filter { $0.name != name }
    }

    public func withoutName(_ names: [String]) -> [Element] {
        filter { !names.contains($0.name) }
    }

    public func withNameStartingWith(_ prefix: String) -> [Element] {
        filter { $0.name.hasPrefix(prefix) }
    }

    public func withNameEndingWith(_ suffix: String) -> [Element] {
        filter { $0.name.hasSuffix(suffix) }
    }

    public func withNameContaining(_ substring: String) -> [Element] {
        filter { $0.name.contains(substring) }
    }

    public func withNameMatching(_ regex: String) -> [Element] {
        filter { $0.name.matches(regex: regex) }
    }

    public func withPrefix(_ prefix: String) -> [Element] {
        withNameStartingWith(prefix)
    }

    public func withSuffix(_ suffix: String) -> [Element] {
        withNameEndingWith(suffix)
    }
}
