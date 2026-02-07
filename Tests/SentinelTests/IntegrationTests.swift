import Testing
@testable import SentinelKit

struct NoForceUnwrapRule: Rule {
    let identifier = "no-force-unwrap"
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.variables(includeNested: true)
            .filter { variable in
                variable.typeAnnotation?.name.hasSuffix("!") == true
            }
            .map { violation(on: $0, message: "Variable '\($0.name)' uses implicitly unwrapped optional.") }
    }
}

struct PublicFinalClassRule: Rule {
    let identifier = "public-final-class"
    let severity: Severity = .info

    func validate(using scope: SentinelScope) -> [Violation] {
        expect("Public classes should be marked final unless designed for inheritance.",
               for: scope.classes().withPublicModifier()) {
            $0.isFinal
        }
    }
}

@Test func endToEndLinting() {
    let source = """
    public class OpenService {
        var name: String! = nil
    }

    public final class ClosedService {
        let id: Int = 0
    }
    """
    let scope = Sentinel.on(source: source)

    let rules: [any Rule] = [
        NoForceUnwrapRule(),
        PublicFinalClassRule(),
    ]

    let runner = RuleRunner(rules: rules, scope: scope)
    let violations = runner.run()

    let warnings = violations.filter { $0.severity == .warning }
    let infos = violations.filter { $0.severity == .info }
    #expect(warnings.count == 1)
    #expect(infos.count == 1)
}

@Test func diagnosticOutputFormat() {
    let violation = Violation(
        ruleIdentifier: "test",
        message: "Test message",
        severity: .error,
        filePath: "/test/File.swift",
        line: 10,
        column: 1
    )
    let output = XcodeDiagnosticFormatter.format(violation)
    #expect(output.contains("error:"))
    #expect(output.contains("[test]"))
    #expect(output.contains("File.swift:10:1"))
}

@Test func compositeRuleChecks() {
    let source = """
    @MainActor class GoodViewModel: BaseViewModel {
        var name: String = ""
    }

    class BadViewModel {
        var data: [String]! = nil
    }

    struct NotAViewModel {}
    """
    let scope = Sentinel.on(source: source)

    struct ViewModelRule: Rule {
        let identifier = "viewmodel-complete"
        let severity: Severity = .error

        func validate(using scope: SentinelScope) -> [Violation] {
            let vms = scope.classes().withNameEndingWith("ViewModel")
            return expect("ViewModels must inherit from BaseViewModel.", for: vms) { $0.inherits(from: "BaseViewModel") }
                 + expect("ViewModels must be annotated with @MainActor.", for: vms) { $0.hasAttribute(named: "MainActor") }
        }
    }

    let rule = ViewModelRule()
    let violations = rule.validate(using: scope)
    #expect(violations.count == 2)
    #expect(violations.allSatisfy { $0.severity == .error })
}

@Test func severityOrdering() {
    #expect(Severity.info < Severity.warning)
    #expect(Severity.warning < Severity.error)
    #expect(!(Severity.error < Severity.warning))
}
