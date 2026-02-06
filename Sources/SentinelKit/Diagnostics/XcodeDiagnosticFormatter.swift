/// Formats violations as Xcode-compatible diagnostic strings.
public enum XcodeDiagnosticFormatter {
    /// Format: /path/to/File.swift:42:1: error: [rule-id] Message
    public static func format(_ violation: Violation) -> String {
        let severityString: String
        switch violation.severity {
        case .error:
            severityString = "error"
        case .warning:
            severityString = "warning"
        case .info:
            severityString = "note"
        }

        return "\(violation.filePath):\(violation.line):\(violation.column): \(severityString): [\(violation.ruleIdentifier)] \(violation.message)"
    }
}
