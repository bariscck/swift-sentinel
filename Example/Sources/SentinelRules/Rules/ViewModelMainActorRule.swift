import SentinelKit

/// ViewModels should be annotated with @MainActor to ensure UI updates happen on the main thread.
struct ViewModelMainActorRule: Rule {
    let identifier = "viewmodel-main-actor"
    let ruleDescription = "ViewModels should be annotated with @MainActor."
    let severity: Severity = .error

    func validate(using scope: SentinelScope) -> [Violation] {
        expect(scope.classes().withNameEndingWith("ViewModel")) {
            $0.hasAttribute(named: "MainActor")
        }
    }
}
