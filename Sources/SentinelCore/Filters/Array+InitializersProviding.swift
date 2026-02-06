extension Array where Element == Initializer {
    public func failable() -> [Initializer] {
        filter { $0.isFailable }
    }

    public func nonFailable() -> [Initializer] {
        filter { !$0.isFailable }
    }
}
