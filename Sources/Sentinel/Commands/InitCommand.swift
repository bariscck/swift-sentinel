import ArgumentParser
import Foundation

struct InitCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Create a .sentinel.yml config file and example rule."
    )

    @Option(name: .shortAndLong, help: "Path to the project directory.")
    var path: String = FileManager.default.currentDirectoryPath

    func run() throws {
        let projectPath = (path as NSString).standardizingPath

        // Create .sentinel.yml
        let configPath = (projectPath as NSString).appendingPathComponent(".sentinel.yml")
        if FileManager.default.fileExists(atPath: configPath) {
            print("Sentinel: .sentinel.yml already exists at \(projectPath)")
        } else {
            let configContent = """
            # Sentinel Configuration
            # https://github.com/example/sentinel

            rules:
              - SentinelRules

            exclude:
              - Tests
              - Generated
            """
            try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
            print("Sentinel: Created .sentinel.yml")
        }

        // Create SentinelRules directory with example rule
        let rulesDir = (projectPath as NSString).appendingPathComponent("SentinelRules")
        try FileManager.default.createDirectory(atPath: rulesDir, withIntermediateDirectories: true)

        let exampleRulePath = (rulesDir as NSString).appendingPathComponent("ExampleRule.swift")
        if FileManager.default.fileExists(atPath: exampleRulePath) {
            print("Sentinel: ExampleRule.swift already exists")
        } else {
            let exampleRule = """
            import SentinelKit

            /// Example rule: ViewModels should be annotated with @MainActor.
            @SentinelRule(.error, id: "viewmodel-main-actor", description: "ViewModels should be annotated with @MainActor.")
            struct ViewModelMainActorRule {
                func validate(using scope: SentinelScope) -> [Violation] {
                    expect("ViewModels should be annotated with @MainActor.",
                           for: scope.classes().withNameEndingWith("ViewModel")) {
                        $0.hasAttribute(annotatedWith: .mainActor)
                    }
                }
            }
            """
            try exampleRule.write(toFile: exampleRulePath, atomically: true, encoding: .utf8)
            print("Sentinel: Created SentinelRules/ExampleRule.swift")
        }

        print("")
        print("Next steps:")
        print("  1. Edit .sentinel.yml to configure rule paths and exclusions")
        print("  2. Write your rules in the SentinelRules/ directory")
        print("  3. Run: sentinel lint")
    }
}
