import ArgumentParser
import SentinelKit
import Foundation

@main
struct SentinelCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sentinel",
        abstract: "A compile-time Swift linting tool with rules written in pure Swift.",
        version: "0.1.0"
    )

    @Option(name: .shortAndLong, help: "Path to the project directory.")
    var path: String = FileManager.default.currentDirectoryPath

    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Paths to exclude from analysis.")
    var exclude: [String] = ["Tests"]

    func run() throws {
        let rules = RuleRegistry.shared.allRules

        guard !rules.isEmpty else {
            print("Sentinel: No rules registered. Register rules using RuleRegistry.shared.register().")
            return
        }

        let configuration = Configuration(
            projectPath: path,
            excludePaths: exclude
        )

        SentinelRunner.run(rules: rules, configuration: configuration)
    }
}
