import Testing
@testable import SentinelKit

@Test func formatsErrorViolation() {
    let violation = Violation(
        ruleIdentifier: "test-rule",
        message: "Something went wrong.",
        severity: .error,
        filePath: "/path/to/File.swift",
        line: 42,
        column: 5
    )
    let formatted = XcodeDiagnosticFormatter.format(violation)
    #expect(formatted == "/path/to/File.swift:42:5: error: [test-rule] Something went wrong.")
}

@Test func formatsWarningViolation() {
    let violation = Violation(
        ruleIdentifier: "warning-rule",
        message: "Consider improving.",
        severity: .warning,
        filePath: "/path/to/Other.swift",
        line: 10,
        column: 1
    )
    let formatted = XcodeDiagnosticFormatter.format(violation)
    #expect(formatted == "/path/to/Other.swift:10:1: warning: [warning-rule] Consider improving.")
}

@Test func formatsInfoViolation() {
    let violation = Violation(
        ruleIdentifier: "info-rule",
        message: "Just FYI.",
        severity: .info,
        filePath: "/path/to/Info.swift",
        line: 1,
        column: 1
    )
    let formatted = XcodeDiagnosticFormatter.format(violation)
    #expect(formatted == "/path/to/Info.swift:1:1: note: [info-rule] Just FYI.")
}
