import SentinelKit

/// Protocols should follow Swift naming conventions:
/// - End with "Protocol", "able", "ible", "ing", "Type", or "Convertible" suffix
@SentinelRule(.info, id: "protocol-naming")
struct ProtocolNamingRule {
    private let validSuffixes = ["Protocol", "able", "ible", "ing", "Type", "Convertible"]

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.protocols()
            .filter { proto in
                !validSuffixes.contains(where: { proto.name.hasSuffix($0) })
            }
            .map { violation(on: $0, message: "Protocol '\($0.name)' should end with a descriptive suffix.") }
    }
}
