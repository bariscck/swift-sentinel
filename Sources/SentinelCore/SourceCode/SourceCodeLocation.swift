import Foundation
import SwiftSyntax

public struct SourceCodeLocation: Sendable {
    public let sourceFilePath: URL?
    public let sourceFileTree: SyntaxProtocol

    public init(sourceFilePath: URL?, sourceFileTree: SyntaxProtocol) {
        self.sourceFilePath = sourceFilePath
        self.sourceFileTree = sourceFileTree
    }

    public var filePath: String {
        sourceFilePath?.path ?? "<unknown>"
    }

    /// Returns the line and column of the given syntax node within this source file.
    public func position(of node: SyntaxProtocol) -> (line: Int, column: Int) {
        let converter = SourceLocationConverter(
            fileName: filePath,
            tree: sourceFileTree
        )
        let location = converter.location(for: node.positionAfterSkippingLeadingTrivia)
        return (line: location.line, column: location.column)
    }
}
