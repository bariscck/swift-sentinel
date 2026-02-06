import SentinelKit

/// Force unwrapping (!) should be avoided to prevent runtime crashes.
struct NoForceUnwrapRule: Rule {
    let identifier = "no-force-unwrap"
    let ruleDescription = "Avoid using implicitly unwrapped optionals (!)."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.variables(includeNested: true)
            .filter { $0.typeAnnotation?.name.hasSuffix("!") == true }
            .map { violation(on: $0, message: "'\($0.name)' uses implicitly unwrapped optional. Use regular optional (?) instead.") }
    }
}
