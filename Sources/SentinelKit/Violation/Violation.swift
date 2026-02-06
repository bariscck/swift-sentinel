import SentinelCore
import SwiftSyntax

public struct Violation: Sendable {
    public let ruleIdentifier: String
    public let message: String
    public let severity: Severity
    public let filePath: String
    public let line: Int
    public let column: Int

    public init(
        ruleIdentifier: String,
        message: String,
        severity: Severity,
        filePath: String,
        line: Int,
        column: Int
    ) {
        self.ruleIdentifier = ruleIdentifier
        self.message = message
        self.severity = severity
        self.filePath = filePath
        self.line = line
        self.column = column
    }
}
