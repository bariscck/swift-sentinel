import SentinelKit

/// All ViewModels should inherit from BaseViewModel for consistent error handling and loading state.
struct ViewModelInheritanceRule: Rule {
    let identifier = "viewmodel-inheritance"
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        expect("ViewModels should inherit from BaseViewModel.",
               for: scope.classes().withNameEndingWith("ViewModel").filter({ $0.name != "BaseViewModel" })) {
            $0.inherits(from: "BaseViewModel")
        }
    }
}
