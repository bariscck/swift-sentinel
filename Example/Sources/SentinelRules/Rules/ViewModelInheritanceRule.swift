import SentinelKit

/// ViewModels must inherit from BaseViewModel for consistent error handling and loading state.
struct ViewModelInheritanceRule: Rule {
    let identifier = "viewmodel-inherits-base"
    let ruleDescription = "ViewModels must inherit from BaseViewModel."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        let viewModels = scope.classes()
            .withNameEndingWith("ViewModel")
            .withoutName("BaseViewModel")

        return expect(viewModels) {
            $0.inherits(from: "BaseViewModel")
        }
    }
}
