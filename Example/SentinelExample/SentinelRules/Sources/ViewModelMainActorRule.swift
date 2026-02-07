import SentinelKit

/// ViewModels should be annotated with @MainActor to ensure UI updates happen on the main thread.
@SentinelRule(.error, id: "viewmodel-main-actor")
struct ViewModelMainActorRule {
    func validate(using scope: SentinelScope) -> [Violation] {
        expect("ViewModels should be annotated with @MainActor.",
               for: scope.classes().withNameEndingWith("ViewModel")) {
            $0.attributes.contains(where: { $0.annotation == .mainActor })
        }
    }
}
