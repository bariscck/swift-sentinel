import SentinelKit

/// ViewModels should be annotated with @MainActor to ensure UI updates happen on the main thread.
struct ViewModelMainActorRule: Rule {
    let identifier = "viewmodel-main-actor"
    let severity: Severity = .error

    func validate(using scope: SentinelScope) -> [Violation] {
        expect("ViewModels should be annotated with @MainActor.",
               for: scope.classes().withNameEndingWith("ViewModel")) {
            $0.attributes.contains(where: { $0.annotation == .mainActor })
        }
    }
}
