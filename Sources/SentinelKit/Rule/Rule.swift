import SentinelCore

/// A lint rule that validates Swift code and produces violations.
public protocol Rule: Sendable {
    /// Unique identifier for this rule (e.g., "viewmodel-main-actor").
    var identifier: String { get }

    /// Human-readable description of what this rule checks.
    var ruleDescription: String { get }

    /// Severity level for violations produced by this rule.
    var severity: Severity { get }

    /// Validates the given scope and returns any violations found.
    func validate(using scope: SentinelScope) -> [Violation]
}
