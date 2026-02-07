import Foundation

/// Parses a simple YAML-subset config file (`.sentinel.yml`).
///
/// Supported format:
/// ```yaml
/// rules:
///   - path/to/Rule.swift
///   - path/to/rules/
///
/// exclude:
///   - Tests
///   - Generated
///
/// include:
///   - Sources
/// ```
struct ConfigParser {
    enum ConfigError: Error, CustomStringConvertible {
        case fileNotFound(String)
        case parseError(String)

        var description: String {
            switch self {
            case .fileNotFound(let path):
                return "Config file not found: \(path)"
            case .parseError(let message):
                return "Config parse error: \(message)"
            }
        }
    }

    /// Parse a `.sentinel.yml` file at the given path.
    static func parse(at path: String) throws -> SentinelConfig {
        guard FileManager.default.fileExists(atPath: path) else {
            throw ConfigError.fileNotFound(path)
        }

        let content = try String(contentsOfFile: path, encoding: .utf8)
        return try parse(content: content)
    }

    /// Parse YAML-subset content string.
    static func parse(content: String) throws -> SentinelConfig {
        var rules: [String] = []
        var exclude: [String] = []
        var include: [String] = []

        var currentSection: String?

        let lines = content.components(separatedBy: .newlines)

        for (index, rawLine) in lines.enumerated() {
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)

            // Skip empty lines and comments
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }

            // Check for section header (top-level key)
            if !rawLine.hasPrefix(" ") && !rawLine.hasPrefix("\t") && trimmed.hasSuffix(":") {
                let key = String(trimmed.dropLast()).trimmingCharacters(in: .whitespaces)
                switch key {
                case "rules", "exclude", "include":
                    currentSection = key
                default:
                    throw ConfigError.parseError("Unknown key '\(key)' at line \(index + 1)")
                }
                continue
            }

            // Check for list item
            if trimmed.hasPrefix("- ") {
                guard let section = currentSection else {
                    throw ConfigError.parseError("List item without section at line \(index + 1)")
                }

                let value = String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                // Remove surrounding quotes if present
                let cleanValue = value
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))

                guard !cleanValue.isEmpty else { continue }

                switch section {
                case "rules":
                    rules.append(cleanValue)
                case "exclude":
                    exclude.append(cleanValue)
                case "include":
                    include.append(cleanValue)
                default:
                    break
                }
                continue
            }

            // Single-value after key (e.g., `rules: path/to/file.swift`)
            if trimmed.contains(":") && !trimmed.hasSuffix(":") {
                let parts = trimmed.split(separator: ":", maxSplits: 1)
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                        .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))

                    switch key {
                    case "rules":
                        currentSection = "rules"
                        if !value.isEmpty { rules.append(value) }
                    case "exclude":
                        currentSection = "exclude"
                        if !value.isEmpty { exclude.append(value) }
                    case "include":
                        currentSection = "include"
                        if !value.isEmpty { include.append(value) }
                    default:
                        throw ConfigError.parseError("Unknown key '\(key)' at line \(index + 1)")
                    }
                }
            }
        }

        return SentinelConfig(rules: rules, exclude: exclude, include: include)
    }
}
