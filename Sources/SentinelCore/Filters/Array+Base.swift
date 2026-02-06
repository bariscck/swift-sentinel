extension Array {
    public func `as`<T>(_ type: T.Type) -> [T] {
        compactMap { $0 as? T }
    }
}
