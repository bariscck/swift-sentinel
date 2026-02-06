import Foundation

extension String {
    func removingLeadingTrailingWhitespace() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func removingBackticks() -> String {
        replacingOccurrences(of: "`", with: "")
    }

    func matches(regex pattern: String) -> Bool {
        range(of: pattern, options: .regularExpression) != nil
    }
}
