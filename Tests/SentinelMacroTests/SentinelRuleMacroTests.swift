import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing
@testable import SentinelMacros

private let testMacros: [String: Macro.Type] = [
    "SentinelRule": SentinelRuleMacro.self,
]

@Test func expandsWithWarning() {
    assertMacroExpansion(
        """
        @SentinelRule(.warning, id: "service_final")
        struct ServiceFinalRule {
            func validate(using scope: SentinelScope) -> [Violation] {
                expect(scope.classes().withNameEndingWith("Service"),
                       message: "Service classes should be marked final.") {
                    $0.isFinal
                }
            }
        }
        """,
        expandedSource: """
        struct ServiceFinalRule {
            func validate(using scope: SentinelScope) -> [Violation] {
                expect(scope.classes().withNameEndingWith("Service"),
                       message: "Service classes should be marked final.") {
                    $0.isFinal
                }
            }

            var identifier: String { "service_final" }

            var severity: Severity { .warning }

            var ruleDescription: String { "Service Final" }
        }

        extension ServiceFinalRule: Rule {
        }
        """,
        macros: testMacros
    )
}

@Test func expandsWithError() {
    assertMacroExpansion(
        """
        @SentinelRule(.error, id: "viewmodel-main-actor")
        struct ViewModelMainActorRule {
            func validate(using scope: SentinelScope) -> [Violation] {
                expect(scope.classes().withNameEndingWith("ViewModel")) {
                    $0.hasAttribute(named: "MainActor")
                }
            }
        }
        """,
        expandedSource: """
        struct ViewModelMainActorRule {
            func validate(using scope: SentinelScope) -> [Violation] {
                expect(scope.classes().withNameEndingWith("ViewModel")) {
                    $0.hasAttribute(named: "MainActor")
                }
            }

            var identifier: String { "viewmodel-main-actor" }

            var severity: Severity { .error }

            var ruleDescription: String { "Viewmodel Main Actor" }
        }

        extension ViewModelMainActorRule: Rule {
        }
        """,
        macros: testMacros
    )
}

@Test func expandsWithCustomDescription() {
    assertMacroExpansion(
        """
        @SentinelRule(.error, id: "viewmodel-main-actor", description: "ViewModels should be annotated with @MainActor.")
        struct ViewModelMainActorRule {
            func validate(using scope: SentinelScope) -> [Violation] {
                expect(scope.classes().withNameEndingWith("ViewModel")) {
                    $0.hasAttribute(named: "MainActor")
                }
            }
        }
        """,
        expandedSource: """
        struct ViewModelMainActorRule {
            func validate(using scope: SentinelScope) -> [Violation] {
                expect(scope.classes().withNameEndingWith("ViewModel")) {
                    $0.hasAttribute(named: "MainActor")
                }
            }

            var identifier: String { "viewmodel-main-actor" }

            var severity: Severity { .error }

            var ruleDescription: String { "ViewModels should be annotated with @MainActor." }
        }

        extension ViewModelMainActorRule: Rule {
        }
        """,
        macros: testMacros
    )
}

@Test func expandsWithInfo() {
    assertMacroExpansion(
        """
        @SentinelRule(.info, id: "protocol_naming")
        struct ProtocolNamingRule {
            func validate(using scope: SentinelScope) -> [Violation] {
                []
            }
        }
        """,
        expandedSource: """
        struct ProtocolNamingRule {
            func validate(using scope: SentinelScope) -> [Violation] {
                []
            }

            var identifier: String { "protocol_naming" }

            var severity: Severity { .info }

            var ruleDescription: String { "Protocol Naming" }
        }

        extension ProtocolNamingRule: Rule {
        }
        """,
        macros: testMacros
    )
}

@Test func skipsExtensionWhenRuleAlreadyDeclared() {
    assertMacroExpansion(
        """
        @SentinelRule(.warning, id: "service_final")
        struct ServiceFinalRule: Rule {
            func validate(using scope: SentinelScope) -> [Violation] {
                []
            }
        }
        """,
        expandedSource: """
        struct ServiceFinalRule: Rule {
            func validate(using scope: SentinelScope) -> [Violation] {
                []
            }

            var identifier: String { "service_final" }

            var severity: Severity { .warning }

            var ruleDescription: String { "Service Final" }
        }
        """,
        macros: testMacros
    )
}
