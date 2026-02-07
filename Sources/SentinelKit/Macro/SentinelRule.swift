/// Automatically synthesizes `identifier`, `severity`, and `ruleDescription` properties for a `Rule` conforming type.
///
/// Usage:
/// ```swift
/// @SentinelRule(.warning, id: "service_final")
/// struct ServiceFinalRule: Rule {
///     func validate(using scope: SentinelScope) -> [Violation] {
///         expect(scope.classes().withNameEndingWith("Service"),
///                message: "Service classes should be marked final.") {
///             $0.isFinal
///         }
///     }
/// }
/// ```
///
/// You can also provide a custom description:
/// ```swift
/// @SentinelRule(.error, id: "viewmodel-main-actor", description: "ViewModels should be annotated with @MainActor.")
/// struct ViewModelMainActorRule: Rule { ... }
/// ```
@attached(member, names: named(identifier), named(severity), named(ruleDescription))
public macro SentinelRule(
    _ severity: Severity,
    id: String,
    description: String? = nil
) = #externalMacro(module: "SentinelMacros", type: "SentinelRuleMacro")
