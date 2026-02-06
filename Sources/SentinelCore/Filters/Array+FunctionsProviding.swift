extension Array where Element == Function {
    public func withReturnType() -> [Function] {
        filter { $0.returnClause != nil }
    }

    public func withoutReturnType() -> [Function] {
        filter { $0.returnClause == nil }
    }

    public func withReturnType(named name: String) -> [Function] {
        filter { $0.returnClause?.typeName == name }
    }

    public func withParameters() -> [Function] {
        filter { !$0.parameters.isEmpty }
    }

    public func withoutParameters() -> [Function] {
        filter { $0.parameters.isEmpty }
    }

    public func withParameterCount(_ count: Int) -> [Function] {
        filter { $0.parameters.count == count }
    }
}
