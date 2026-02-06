extension Array where Element: AttributesProviding {
    public func withAttribute(_ predicate: (Attribute) -> Bool) -> [Element] {
        filter { $0.attributes.contains(where: predicate) }
    }

    public func withAttribute(named name: String) -> [Element] {
        filter { $0.hasAttribute(named: name) }
    }

    public func withoutAttribute(named name: String) -> [Element] {
        filter { !$0.hasAttribute(named: name) }
    }

    public func withAttribute(annotatedWith annotation: Annotation) -> [Element] {
        filter { $0.hasAttribute(annotatedWith: annotation) }
    }

    public func withoutAttribute(annotatedWith annotation: Annotation) -> [Element] {
        filter { !$0.hasAttribute(annotatedWith: annotation) }
    }
}
