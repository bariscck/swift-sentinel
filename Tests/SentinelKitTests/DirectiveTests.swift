import Testing
@testable import SentinelKit

// MARK: - Test Rule

private struct TestRule: Rule {
    let identifier = "test-rule"
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.classes(includeNested: false).map { cls in
            violation(on: cls, message: "Test violation on \(cls.name)")
        }
    }
}

private struct SecondTestRule: Rule {
    let identifier = "second-rule"
    let severity: Severity = .error

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.classes(includeNested: false).map { cls in
            violation(on: cls, message: "Second violation on \(cls.name)")
        }
    }
}

// MARK: - DirectiveParser Tests

@Suite("DirectiveParser")
struct DirectiveParserTests {

    @Test func parsesDisableDirective() {
        let source = "// sentinel:disable test-rule\nclass Foo {}"
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.count == 1)
        #expect(directives[0].action == .disable)
        #expect(directives[0].scope == .fromHere)
        #expect(directives[0].ruleIdentifier == "test-rule")
        #expect(directives[0].line == 1)
    }

    @Test func parsesEnableDirective() {
        let source = "// sentinel:enable test-rule"
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.count == 1)
        #expect(directives[0].action == .enable)
        #expect(directives[0].scope == .fromHere)
        #expect(directives[0].ruleIdentifier == "test-rule")
    }

    @Test func parsesDisableNextDirective() {
        let source = "// sentinel:disable:next test-rule\nclass Foo {}"
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.count == 1)
        #expect(directives[0].action == .disable)
        #expect(directives[0].scope == .nextLine)
        #expect(directives[0].ruleIdentifier == "test-rule")
    }

    @Test func parsesDisableThisDirective() {
        let source = "class Foo {} // sentinel:disable:this test-rule"
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.count == 1)
        #expect(directives[0].action == .disable)
        #expect(directives[0].scope == .thisLine)
        #expect(directives[0].ruleIdentifier == "test-rule")
    }

    @Test func parsesAllKeyword() {
        let source = "// sentinel:disable all"
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.count == 1)
        #expect(directives[0].ruleIdentifier == nil)
    }

    @Test func parsesMultipleDirectives() {
        let source = """
        // sentinel:disable test-rule
        class Foo {}
        // sentinel:enable test-rule
        class Bar {}
        """
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.count == 2)
        #expect(directives[0].action == .disable)
        #expect(directives[0].line == 1)
        #expect(directives[1].action == .enable)
        #expect(directives[1].line == 3)
    }

    @Test func ignoresNonDirectiveComments() {
        let source = """
        // This is a regular comment
        // sentinel is great
        /// Doc comment about sentinel:disable
        class Foo {}
        """
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.isEmpty)
    }

    @Test func handlesExtraWhitespace() {
        let source = "   //   sentinel:disable   test-rule  "
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.count == 1)
        #expect(directives[0].ruleIdentifier == "test-rule")
    }

    @Test func preservesRuleIdentifierCasing() {
        let source = "// sentinel:disable My-Custom-Rule"
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.count == 1)
        #expect(directives[0].ruleIdentifier == "My-Custom-Rule")
    }

    @Test func correctLineNumbers() {
        let source = """
        import Foundation

        // sentinel:disable test-rule
        class Foo {}
        // sentinel:disable:next second-rule
        class Bar {}
        """
        let directives = DirectiveParser.parse(source: source)
        #expect(directives.count == 2)
        #expect(directives[0].line == 3)
        #expect(directives[1].line == 5)
    }
}

// MARK: - DirectiveFilter Tests

@Suite("DirectiveFilter")
struct DirectiveFilterTests {

    @Test func disableFromHereSuppressesViolation() {
        let source = """
        // sentinel:disable test-rule
        class Foo {}
        """
        let scope = Sentinel.on(source: source)
        let rule = TestRule()
        let allViolations = rule.validate(using: scope)
        #expect(allViolations.count == 1)

        let filtered = DirectiveFilter.filter(violations: allViolations, sourceCode: scope.sourceCode)
        #expect(filtered.isEmpty)
    }

    @Test func disableThisSuppressesOnSameLine() {
        let source = "class Foo {} // sentinel:disable:this test-rule"
        let scope = Sentinel.on(source: source)
        let rule = TestRule()
        let allViolations = rule.validate(using: scope)
        #expect(allViolations.count == 1)

        let filtered = DirectiveFilter.filter(violations: allViolations, sourceCode: scope.sourceCode)
        #expect(filtered.isEmpty)
    }

    @Test func disableNextSuppressesNextLine() {
        let source = """
        // sentinel:disable:next test-rule
        class Foo {}
        """
        let scope = Sentinel.on(source: source)
        let rule = TestRule()
        let allViolations = rule.validate(using: scope)
        #expect(allViolations.count == 1)

        let filtered = DirectiveFilter.filter(violations: allViolations, sourceCode: scope.sourceCode)
        #expect(filtered.isEmpty)
    }

    @Test func disableNextDoesNotAffectLaterLines() {
        let source = """
        // sentinel:disable:next test-rule
        class Foo {}
        class Bar {}
        """
        let scope = Sentinel.on(source: source)
        let rule = TestRule()
        let allViolations = rule.validate(using: scope)
        #expect(allViolations.count == 2)

        let filtered = DirectiveFilter.filter(violations: allViolations, sourceCode: scope.sourceCode)
        #expect(filtered.count == 1)
        #expect(filtered[0].message.contains("Bar"))
    }

    @Test func enableReEnablesRule() {
        let source = """
        // sentinel:disable test-rule
        class Foo {}
        // sentinel:enable test-rule
        class Bar {}
        """
        let scope = Sentinel.on(source: source)
        let rule = TestRule()
        let allViolations = rule.validate(using: scope)
        #expect(allViolations.count == 2)

        let filtered = DirectiveFilter.filter(violations: allViolations, sourceCode: scope.sourceCode)
        #expect(filtered.count == 1)
        #expect(filtered[0].message.contains("Bar"))
    }

    @Test func disableAllSuppressesAllRules() {
        let source = """
        // sentinel:disable all
        class Foo {}
        """
        let scope = Sentinel.on(source: source)
        let rules: [any Rule] = [TestRule(), SecondTestRule()]
        let runner = RuleRunner(rules: rules, scope: scope)
        let violations = runner.run()
        #expect(violations.isEmpty)
    }

    @Test func disableSpecificRuleOnlyAffectsThatRule() {
        let source = """
        // sentinel:disable test-rule
        class Foo {}
        """
        let scope = Sentinel.on(source: source)
        let rules: [any Rule] = [TestRule(), SecondTestRule()]
        let runner = RuleRunner(rules: rules, scope: scope)
        let violations = runner.run()
        #expect(violations.count == 1)
        #expect(violations[0].ruleIdentifier == "second-rule")
    }

    @Test func noDirectivesMeansNoFiltering() {
        let source = """
        class Foo {}
        class Bar {}
        """
        let scope = Sentinel.on(source: source)
        let rule = TestRule()
        let allViolations = rule.validate(using: scope)
        let filtered = DirectiveFilter.filter(violations: allViolations, sourceCode: scope.sourceCode)
        #expect(filtered.count == allViolations.count)
    }

    @Test func disableEnableDisableSequence() {
        let source = """
        // sentinel:disable test-rule
        class Foo {}
        // sentinel:enable test-rule
        class Bar {}
        // sentinel:disable test-rule
        class Baz {}
        """
        let scope = Sentinel.on(source: source)
        let rule = TestRule()
        let allViolations = rule.validate(using: scope)
        #expect(allViolations.count == 3)

        let filtered = DirectiveFilter.filter(violations: allViolations, sourceCode: scope.sourceCode)
        #expect(filtered.count == 1)
        #expect(filtered[0].message.contains("Bar"))
    }
}

// MARK: - RuleRunner Integration Tests

@Suite("RuleRunner with directives")
struct RuleRunnerDirectiveTests {

    @Test func runnerFiltersDirectiveSuppressedViolations() {
        let source = """
        // sentinel:disable test-rule
        class Foo {}
        """
        let scope = Sentinel.on(source: source)
        let runner = RuleRunner(rules: [TestRule()], scope: scope)
        let violations = runner.run()
        #expect(violations.isEmpty)
    }

    @Test func runnerKeepsNonSuppressedViolations() {
        let source = """
        class Foo {}
        // sentinel:disable:next test-rule
        class Bar {}
        class Baz {}
        """
        let scope = Sentinel.on(source: source)
        let runner = RuleRunner(rules: [TestRule()], scope: scope)
        let violations = runner.run()
        #expect(violations.count == 2)
    }
}
