import Foundation

/// Parses sentinel inline directives from Swift source code comments.
///
/// Recognized patterns (case-insensitive prefix match after `//`):
/// ```
/// // sentinel:disable <rule-id|all>
/// // sentinel:enable <rule-id|all>
/// // sentinel:disable:next <rule-id|all>
/// // sentinel:disable:this <rule-id|all>
/// ```
public enum DirectiveParser {

    /// Parse all inline directives from the given source string.
    public static func parse(source: String) -> [InlineDirective] {
        var directives: [InlineDirective] = []
        let lines = source.components(separatedBy: .newlines)

        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1
            if let directive = parseDirective(from: line, at: lineNumber) {
                directives.append(directive)
            }
        }

        return directives
    }

    // MARK: - Private

    private static func parseDirective(from line: String, at lineNumber: Int) -> InlineDirective? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        // Find the comment portion: must start with // or contain //
        guard let commentBody = extractCommentBody(from: trimmed) else {
            return nil
        }

        let tokens = commentBody
            .trimmingCharacters(in: .whitespaces)
            .lowercased()
            .split(separator: " ", omittingEmptySubsequences: true)
            .map(String.init)

        guard tokens.count >= 2,
              let (action, scope) = parseActionAndScope(tokens[0]) else {
            return nil
        }

        let ruleId = parseRuleIdentifier(tokens[1], from: line)

        return InlineDirective(
            action: action,
            scope: scope,
            ruleIdentifier: ruleId,
            line: lineNumber
        )
    }

    private static func extractCommentBody(from line: String) -> String? {
        // Look for // sentinel: pattern
        guard let range = line.range(of: "//") else {
            return nil
        }
        let afterSlashes = String(line[range.upperBound...])
            .trimmingCharacters(in: .whitespaces)

        // Must start with sentinel:
        guard afterSlashes.lowercased().hasPrefix("sentinel:") else {
            return nil
        }

        return afterSlashes
    }

    private static func parseActionAndScope(_ token: String) -> (InlineDirective.Action, InlineDirective.Scope)? {
        switch token {
        case "sentinel:disable":
            return (.disable, .fromHere)
        case "sentinel:enable":
            return (.enable, .fromHere)
        case "sentinel:disable:next":
            return (.disable, .nextLine)
        case "sentinel:disable:this":
            return (.disable, .thisLine)
        default:
            return nil
        }
    }

    /// Extract the original-cased rule identifier from the raw line.
    private static func parseRuleIdentifier(_ lowercasedToken: String, from originalLine: String) -> String? {
        if lowercasedToken == "all" {
            return nil
        }

        // Find the actual token in the original line to preserve casing
        let components = originalLine.components(separatedBy: "//")
        guard components.count >= 2 else { return lowercasedToken }

        let commentPart = components.dropFirst().joined(separator: "//")
        let words = commentPart
            .trimmingCharacters(in: .whitespaces)
            .split(separator: " ", omittingEmptySubsequences: true)
            .map(String.init)

        // The rule identifier is the second word after `sentinel:disable` etc.
        guard words.count >= 2 else { return lowercasedToken }

        return words[1]
    }
}
