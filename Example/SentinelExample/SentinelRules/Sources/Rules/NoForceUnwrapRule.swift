import SentinelKit

/// Variables should not use implicitly unwrapped optionals (force unwrap).
/// Use proper optionals or default values instead.
struct NoForceUnwrapRule: Rule {
    let identifier = "no-force-unwrap"
    let ruleDescription = "Avoid implicitly unwrapped optionals."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.classes()
            .flatMap { $0.variables() }
            .filter { $0.typeAnnotation?.name.hasSuffix("!") == true }
            .map { violation(on: $0, message: "Variable '\($0.name)' uses implicitly unwrapped optional. Use '?' instead.") }
    }
}
