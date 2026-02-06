import SentinelKit

/// Public classes should be marked `final` unless explicitly designed for inheritance.
/// This prevents unintended subclassing and improves performance through static dispatch.
struct PublicFinalClassRule: Rule {
    let identifier = "public-final-class"
    let ruleDescription = "Public classes should be marked final."
    let severity: Severity = .info

    func validate(using scope: SentinelScope) -> [Violation] {
        expect(scope.classes().withPublicModifier()) {
            $0.isFinal
        }
    }
}
