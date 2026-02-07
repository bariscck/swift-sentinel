import Testing
@testable import SentinelKit

struct DummyRule: Rule {
    let identifier: String
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] { [] }
}

@Test func registryStoresRules() {
    let registry = RuleRegistry.shared
    registry.reset()

    registry.register(DummyRule(identifier: "rule-1"))
    registry.register(DummyRule(identifier: "rule-2"))

    #expect(registry.allRules.count == 2)
    registry.reset()
    #expect(registry.allRules.isEmpty)
}

@Test func registryAcceptsBatchRegistration() {
    let registry = RuleRegistry.shared
    registry.reset()

    registry.register([
        DummyRule(identifier: "a"),
        DummyRule(identifier: "b"),
        DummyRule(identifier: "c"),
    ])

    #expect(registry.allRules.count == 3)
    registry.reset()
}
