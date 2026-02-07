/// Automatically synthesizes `Rule` conformance along with `identifier` and `severity` properties.
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
@attached(member, names: named(identifier), named(severity))
@attached(extension, conformances: Rule)
public macro SentinelRule(
    _ severity: Severity,
    id: String
) = #externalMacro(module: "SentinelMacros", type: "SentinelRuleMacro")
