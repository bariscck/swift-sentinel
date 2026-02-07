import SentinelKit

/// All ViewModels should inherit from BaseViewModel for consistent error handling and loading state.
struct ViewModelInheritanceRule: Rule {
    let identifier = "viewmodel-inheritance"
    let ruleDescription = "ViewModels should inherit from BaseViewModel."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        expect(for: scope.classes().withNameEndingWith("ViewModel").filter({ $0.name != "BaseViewModel" })) {
            $0.inherits(from: "BaseViewModel")
        }
    }
}
