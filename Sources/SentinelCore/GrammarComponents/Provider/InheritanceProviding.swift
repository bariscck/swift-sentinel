public protocol InheritanceProviding: Declaration {
    var inheritanceTypesNames: [String] { get }
}

extension InheritanceProviding {
    public func inherits(from name: String) -> Bool {
        inheritanceTypesNames.contains(name)
    }

    public func inherits(from names: [String]) -> Bool {
        names.allSatisfy { inherits(from: $0) }
    }

    public func conforms(to protocolName: String) -> Bool {
        inheritanceTypesNames.contains(protocolName)
    }

    public func conforms(to protocolNames: [String]) -> Bool {
        protocolNames.allSatisfy { conforms(to: $0) }
    }
}
