public protocol AccessorBlocksProviding: Declaration {
    var accessors: [AccessorBlock] { get }
    var getter: GetterBlock? { get }
}

extension AccessorBlocksProviding {
    public func hasGetAccessor() -> Bool {
        accessors.contains { $0.kind == .get }
    }

    public func hasSetAccessor() -> Bool {
        accessors.contains { $0.kind == .set }
    }

    public func hasWillSetAccessor() -> Bool {
        accessors.contains { $0.kind == .willSet }
    }

    public func hasDidSetAccessor() -> Bool {
        accessors.contains { $0.kind == .didSet }
    }
}
