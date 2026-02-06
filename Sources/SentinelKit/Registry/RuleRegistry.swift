import Foundation

/// Central registry for lint rules.
public final class RuleRegistry: @unchecked Sendable {
    public static let shared = RuleRegistry()

    private var rules: [any Rule] = []
    private let lock = NSLock()

    private init() {}

    /// Register a single rule.
    public func register(_ rule: any Rule) {
        lock.lock()
        defer { lock.unlock() }
        rules.append(rule)
    }

    /// Register multiple rules.
    public func register(_ rules: [any Rule]) {
        lock.lock()
        defer { lock.unlock() }
        self.rules.append(contentsOf: rules)
    }

    /// All registered rules.
    public var allRules: [any Rule] {
        lock.lock()
        defer { lock.unlock() }
        return rules
    }

    /// Remove all registered rules.
    public func reset() {
        lock.lock()
        defer { lock.unlock() }
        rules.removeAll()
    }
}
