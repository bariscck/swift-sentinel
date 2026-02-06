import SentinelKit

/// Protocols should follow Swift naming conventions:
/// - End with "Protocol", "able", "ible", "ing", "Type", or "Convertible" suffix
struct ProtocolNamingRule: Rule {
    let identifier = "protocol-naming"
    let ruleDescription = "Protocols should end with a descriptive suffix (e.g., Protocol, able, ible, ing)."
    let severity: Severity = .info

    private let validSuffixes = ["Protocol", "able", "ible", "ing", "Type", "Convertible"]

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.protocols()
            .filter { proto in
                !validSuffixes.contains(where: { proto.name.hasSuffix($0) })
            }
            .map { violation(on: $0, message: "Protocol '\($0.name)' should end with a descriptive suffix.") }
    }
}
