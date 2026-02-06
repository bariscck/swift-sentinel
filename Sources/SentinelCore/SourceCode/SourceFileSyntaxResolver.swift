import Foundation
import SwiftSyntax
import SwiftParser

struct SourceFileSyntaxResolver {
    let source: String
    let url: URL?

    func resolve() -> (tree: SourceFileSyntax, collector: DeclarationsCollector) {
        let tree = Parser.parse(source: source)
        let location = SourceCodeLocation(sourceFilePath: url, sourceFileTree: tree)
        let collector = DeclarationsCollector(sourceCodeLocation: location)
        collector.walk(tree)
        return (tree, collector)
    }
}
