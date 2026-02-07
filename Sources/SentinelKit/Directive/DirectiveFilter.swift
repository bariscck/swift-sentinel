import SentinelCore

/// Filters violations based on inline sentinel directives found in source files.
public enum DirectiveFilter {

    /// Removes violations that are suppressed by inline directives in the source code.
    public static func filter(
        violations: [Violation],
        sourceCode: [SwiftSourceCode]
    ) -> [Violation] {
        // Build a lookup: filePath -> [InlineDirective]
        var directivesByFile: [String: [InlineDirective]] = [:]
        for source in sourceCode {
            let filePath = source.filePath ?? "<unknown>"
            let directives = DirectiveParser.parse(source: source.source)
            if !directives.isEmpty {
                directivesByFile[filePath] = directives
            }
        }

        guard !directivesByFile.isEmpty else {
            return violations
        }

        return violations.filter { violation in
            guard let directives = directivesByFile[violation.filePath] else {
                return true // No directives for this file — keep violation
            }
            return !isSuppressed(violation: violation, by: directives)
        }
    }

    // MARK: - Private

    private static func isSuppressed(
        violation: Violation,
        by directives: [InlineDirective]
    ) -> Bool {
        for directive in directives {
            guard matchesRule(directive: directive, ruleIdentifier: violation.ruleIdentifier) else {
                continue
            }

            switch directive.scope {
            case .thisLine:
                if violation.line == directive.line {
                    return true
                }

            case .nextLine:
                if violation.line == directive.line + 1 {
                    return true
                }

            case .fromHere:
                if directive.action == .disable && violation.line >= directive.line {
                    // Check if there's a later enable that re-enables before this violation
                    let reEnabled = directives.contains { other in
                        other.action == .enable
                            && other.scope == .fromHere
                            && matchesRule(directive: other, ruleIdentifier: violation.ruleIdentifier)
                            && other.line > directive.line
                            && other.line <= violation.line
                    }
                    if !reEnabled {
                        return true
                    }
                }
            }
        }

        return false
    }

    private static func matchesRule(directive: InlineDirective, ruleIdentifier: String) -> Bool {
        guard let directiveRule = directive.ruleIdentifier else {
            return true // nil means "all rules"
        }
        return directiveRule == ruleIdentifier
    }
}
