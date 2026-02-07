/// Represents a sentinel inline directive parsed from a source code comment.
///
/// Supported comment formats:
/// - `// sentinel:disable <rule-id>` — disable rule from this line to end of file (or until re-enabled)
/// - `// sentinel:enable <rule-id>` — re-enable a previously disabled rule
/// - `// sentinel:disable:next <rule-id>` — disable rule for the next line only
/// - `// sentinel:disable:this <rule-id>` — disable rule for this line only
///
/// Use `all` as rule-id to target every rule.
public struct InlineDirective: Sendable, Equatable {
    public enum Action: Sendable, Equatable {
        case disable
        case enable
    }

    public enum Scope: Sendable, Equatable {
        /// Applies from the directive line until a matching `enable` or end of file.
        case fromHere
        /// Applies only to the line where the directive appears.
        case thisLine
        /// Applies only to the line immediately after the directive.
        case nextLine
    }

    public let action: Action
    public let scope: Scope
    /// The rule identifier to target. `nil` means all rules.
    public let ruleIdentifier: String?
    /// The 1-based line number where this directive appears.
    public let line: Int

    public init(action: Action, scope: Scope, ruleIdentifier: String?, line: Int) {
        self.action = action
        self.scope = scope
        self.ruleIdentifier = ruleIdentifier
        self.line = line
    }
}
