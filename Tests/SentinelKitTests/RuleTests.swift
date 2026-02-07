import Testing
@testable import SentinelKit

// MARK: - Test Rules

struct MainActorViewModelRule: Rule {
    let identifier = "viewmodel-main-actor"
    let severity: Severity = .error

    func validate(using scope: SentinelScope) -> [Violation] {
        expect("ViewModels should be annotated with @MainActor.",
               for: scope.classes().withNameEndingWith("ViewModel")) {
            $0.hasAttribute(named: "MainActor")
        }
    }
}

struct ViewModelInheritanceRule: Rule {
    let identifier = "viewmodel-inherits-base"
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        expect("ViewModels must inherit from BaseViewModel.",
               for: scope.classes().withNameEndingWith("ViewModel")) {
            $0.inherits(from: "BaseViewModel")
        }
    }
}

// MARK: - Tests

@Test func ruleDetectsViolation() {
    let scope = Sentinel.on(source: """
    class MyViewModel {
        var name: String = ""
    }
    """)

    let rule = MainActorViewModelRule()
    let violations = rule.validate(using: scope)
    #expect(violations.count == 1)
    #expect(violations[0].ruleIdentifier == "viewmodel-main-actor")
    #expect(violations[0].severity == .error)
}

@Test func rulePassesWhenSatisfied() {
    let scope = Sentinel.on(source: """
    @MainActor
    class MyViewModel {
        var name: String = ""
    }
    """)

    let rule = MainActorViewModelRule()
    let violations = rule.validate(using: scope)
    #expect(violations.isEmpty)
}

@Test func ruleIgnoresNonViewModels() {
    let scope = Sentinel.on(source: """
    class UserService {}
    class NetworkManager {}
    """)

    let rule = MainActorViewModelRule()
    let violations = rule.validate(using: scope)
    #expect(violations.isEmpty)
}

@Test func multipleRulesCompose() {
    let scope = Sentinel.on(source: """
    class BadViewModel {}
    @MainActor class BetterViewModel {}
    @MainActor class GoodViewModel: BaseViewModel {}
    """)

    let rules: [any Rule] = [
        MainActorViewModelRule(),
        ViewModelInheritanceRule(),
    ]

    let runner = RuleRunner(rules: rules, scope: scope)
    let violations = runner.run()

    // BadViewModel: missing @MainActor (error) + missing BaseViewModel (warning)
    // BetterViewModel: missing BaseViewModel (warning)
    // GoodViewModel: passes both
    let errors = violations.filter { $0.severity == .error }
    let warnings = violations.filter { $0.severity == .warning }
    #expect(errors.count == 1)  // BadViewModel missing @MainActor
    #expect(warnings.count == 2)  // BadViewModel + BetterViewModel missing BaseViewModel
}

@Test func expectDSLProducesCorrectViolations() {
    let scope = Sentinel.on(source: """
    class FirstViewModel {}
    class SecondViewModel: BaseViewModel {}
    class ThirdViewModel {}
    """)

    let rule = ViewModelInheritanceRule()
    let violations = rule.validate(using: scope)
    #expect(violations.count == 2)
    #expect(violations.allSatisfy { $0.severity == .warning })
}

@Test func violationContainsCorrectMetadata() {
    let scope = Sentinel.on(source: """
    class TestViewModel {}
    """)

    let rule = MainActorViewModelRule()
    let violations = rule.validate(using: scope)
    #expect(violations.count == 1)

    let v = violations[0]
    #expect(v.ruleIdentifier == "viewmodel-main-actor")
    #expect(v.message == "ViewModels should be annotated with @MainActor.")
    #expect(v.severity == .error)
    #expect(v.line >= 1)
}
