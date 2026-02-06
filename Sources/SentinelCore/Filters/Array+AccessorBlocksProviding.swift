extension Array where Element: AccessorBlocksProviding {
    public func withGetAccessor() -> [Element] {
        filter { $0.hasGetAccessor() }
    }

    public func withSetAccessor() -> [Element] {
        filter { $0.hasSetAccessor() }
    }

    public func withWillSetAccessor() -> [Element] {
        filter { $0.hasWillSetAccessor() }
    }

    public func withDidSetAccessor() -> [Element] {
        filter { $0.hasDidSetAccessor() }
    }
}
