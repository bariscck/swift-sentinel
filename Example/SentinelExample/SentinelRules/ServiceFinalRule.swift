import SentinelKit

/// Service classes should be marked `final` to prevent subclassing.
/// Use protocols + dependency injection instead of inheritance for service abstraction.
struct ServiceFinalRule: Rule {
    let identifier = "service-final"
    let ruleDescription = "Service classes should be marked final."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        expect(scope.classes().withNameEndingWith("Service")) {
            $0.isFinal
        }
    }
}
