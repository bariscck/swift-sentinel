extension Array where Element == Class {
    public func withSuperclass(_ name: String) -> [Class] {
        filter { $0.inherits(from: name) }
    }

    public func withoutSuperclass(_ name: String) -> [Class] {
        filter { !$0.inherits(from: name) }
    }
}
