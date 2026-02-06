/// Builder protocol for specifying folders to exclude.
public protocol Excluding: SentinelScope {
    func excluding(_ excludes: String...) -> SentinelScope
    func excluding(_ excludes: [String]) -> SentinelScope
}
