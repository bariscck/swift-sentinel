public enum Severity: String, Sendable, Comparable, CaseIterable {
    case info
    case warning
    case error

    public static func < (lhs: Severity, rhs: Severity) -> Bool {
        let order: [Severity] = [.info, .warning, .error]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}
