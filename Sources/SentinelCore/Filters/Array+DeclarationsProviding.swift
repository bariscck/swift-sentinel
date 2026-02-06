extension Array where Element: DeclarationsProviding {
    public func withDeclarations(_ predicate: ([Declaration]) -> Bool) -> [Element] {
        filter { predicate($0.declarations) }
    }

    public func withClasses() -> [Element] {
        filter { !$0.classes().isEmpty }
    }

    public func withStructs() -> [Element] {
        filter { !$0.structs().isEmpty }
    }

    public func withEnums() -> [Element] {
        filter { !$0.enums().isEmpty }
    }

    public func withFunctions() -> [Element] {
        filter { !$0.functions().isEmpty }
    }

    public func withVariables() -> [Element] {
        filter { !$0.variables().isEmpty }
    }
}
