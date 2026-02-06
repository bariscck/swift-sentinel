public protocol AttributesProviding: Declaration {
    var attributes: [Attribute] { get }
}

extension AttributesProviding {
    public func hasAttribute(named name: String) -> Bool {
        attributes.contains { $0.name == name || $0.name == "@\(name)" }
    }

    public func hasAttribute(annotatedWith annotation: Annotation) -> Bool {
        attributes.contains { $0.annotation == annotation }
    }

    public func attribute(named name: String) -> Attribute? {
        attributes.first { $0.name == name || $0.name == "@\(name)" }
    }
}
