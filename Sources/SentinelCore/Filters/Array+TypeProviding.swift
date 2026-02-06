extension Array where Element: TypeProviding {
    public func withType(_ predicate: (TypeAnnotation) -> Bool) -> [Element] {
        filter {
            guard let type = $0.typeAnnotation else { return false }
            return predicate(type)
        }
    }

    public func withType(named name: String) -> [Element] {
        filter { $0.typeAnnotation?.name == name }
    }

    public func withOptionalType() -> [Element] {
        filter { $0.typeAnnotation?.isOptional == true }
    }

    public func withNonOptionalType() -> [Element] {
        filter { $0.typeAnnotation?.isOptional == false }
    }

    public func withInferredType() -> [Element] {
        filter { $0.typeAnnotation == nil }
    }

    public func withExplicitType() -> [Element] {
        filter { $0.typeAnnotation != nil }
    }
}
