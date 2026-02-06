extension Array where Element: InheritanceProviding {
    public func inheriting(from name: String) -> [Element] {
        filter { $0.inherits(from: name) }
    }

    public func notInheriting(from name: String) -> [Element] {
        filter { !$0.inherits(from: name) }
    }

    public func conforming(to protocolName: String) -> [Element] {
        filter { $0.conforms(to: protocolName) }
    }

    public func notConforming(to protocolName: String) -> [Element] {
        filter { !$0.conforms(to: protocolName) }
    }

    public func conforming(to protocolNames: [String]) -> [Element] {
        filter { $0.conforms(to: protocolNames) }
    }

    public func conforming(to protocolNames: String...) -> [Element] {
        conforming(to: protocolNames)
    }
}
