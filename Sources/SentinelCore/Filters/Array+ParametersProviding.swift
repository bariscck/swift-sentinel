extension Array where Element: ParametersProviding {
    public func withParameters(_ predicate: ([Parameter]) -> Bool) -> [Element] {
        filter { predicate($0.parameters) }
    }

    public func withParameterCount(_ count: Int) -> [Element] {
        filter { $0.parameters.count == count }
    }
}
