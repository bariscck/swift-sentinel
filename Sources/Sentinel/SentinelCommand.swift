import ArgumentParser
import Foundation

@main
struct SentinelCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "sentinel",
        abstract: "A compile-time Swift linting tool with rules written in pure Swift.",
        version: "0.2.0",
        subcommands: [LintCommand.self, InitCommand.self],
        defaultSubcommand: LintCommand.self
    )
}
