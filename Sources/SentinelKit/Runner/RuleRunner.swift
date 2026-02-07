import SentinelCore

/// Executes rules against a scope and collects violations.
public struct RuleRunner: Sendable {
    private let rules: [any Rule]
    private let scope: SentinelScope

    public init(rules: [any Rule], scope: SentinelScope) {
        self.rules = rules
        self.scope = scope
    }

    /// Run all rules and return all violations, filtering out those suppressed by inline directives.
    public func run() -> [Violation] {
        let violations = rules.flatMap { rule in
            rule.validate(using: scope)
        }
        return DirectiveFilter.filter(violations: violations, sourceCode: scope.sourceCode)
    }
}
