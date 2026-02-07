/// Automatically synthesizes `Rule` conformance along with `identifier`, `severity`, and `ruleDescription` properties.
///
/// Usage:
/// ```swift
/// @SentinelRule(.warning, id: "service_final")
/// struct ServiceFinalRule {
///     func validate(using scope: SentinelScope) -> [Violation] {
///         expect("Service classes should be marked final.",
///                for: scope.classes().withNameEndingWith("Service")) {
///             $0.isFinal
///         }
///     }
/// }
/// ```
///
/// You can also provide a custom description:
/// ```swift
/// @SentinelRule(.error, id: "viewmodel-main-actor", description: "ViewModels should be annotated with @MainActor.")
/// struct ViewModelMainActorRule { ... }
/// ```
@attached(member, names: named(identifier), named(severity), named(ruleDescription))
@attached(extension, conformances: Rule)
public macro SentinelRule(
    _ severity: Severity,
    id: String,
    description: String? = nil
) = #externalMacro(module: "SentinelMacros", type: "SentinelRuleMacro")
