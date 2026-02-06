extension Array where Element == Variable {
    public func constants() -> [Variable] {
        filter { $0.isConstant }
    }

    public func variables() -> [Variable] {
        filter { $0.isVariable }
    }

    public func computed() -> [Variable] {
        filter { $0.isComputed }
    }

    public func stored() -> [Variable] {
        filter { $0.isStored }
    }

    public func optional() -> [Variable] {
        filter { $0.isOptional }
    }

    public func nonOptional() -> [Variable] {
        filter { !$0.isOptional }
    }

    public func ofInferredType() -> [Variable] {
        filter { $0.isOfInferredType }
    }
}
