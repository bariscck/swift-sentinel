extension Array where Element: BodyProviding {
    public func withBody(_ predicate: (Body) -> Bool) -> [Element] {
        filter {
            guard let body = $0.body else { return false }
            return predicate(body)
        }
    }

    public func withBody() -> [Element] {
        filter { $0.body != nil }
    }

    public func withoutBody() -> [Element] {
        filter { $0.body == nil }
    }

    public func withEmptyBody() -> [Element] {
        filter { $0.isEmptyBody }
    }

    public func withNonEmptyBody() -> [Element] {
        filter { !$0.isEmptyBody }
    }

    public func withBodyContaining(_ substring: String) -> [Element] {
        filter { $0.body?.content.contains(substring) == true }
    }

    public func withBodyMatching(_ regex: String) -> [Element] {
        filter { $0.body?.content.matches(regex: regex) == true }
    }

    public func withSelfReference() -> [Element] {
        filter { $0.refersToSelf }
    }
}
