import SentinelKit

/// Service classes should be marked `final` to prevent subclassing.
/// Use protocols + dependency injection instead of inheritance for service abstraction.
@SentinelRule(.warning, id: "service-final")
struct ServiceFinalRule {
    func validate(using scope: SentinelScope) -> [Violation] {
        expect("Service classes should be marked final.",
               for: scope.classes().withNameEndingWith("Service")) {
            $0.isFinal
        }
    }
}
