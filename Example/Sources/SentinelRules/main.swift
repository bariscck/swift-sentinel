import SentinelKit

// Register all rules and run Sentinel against the App target.
// This executable is designed to be run as an Xcode Build Phase:
//
//   swift run --package-path path/to/Example SentinelRules
//
// Output will appear as inline Xcode warnings and errors.

SentinelRunner.run(
    rules: [
        // ViewModel conventions
        ViewModelMainActorRule(),
        ViewModelInheritanceRule(),

        // Code safety
        NoForceUnwrapRule(),

        // Architecture
        PublicFinalClassRule(),
        ServiceFinalRule(),

        // Naming
        ProtocolNamingRule(),
    ],
    configuration: Configuration(
        projectPath: "Sources/App",
        excludePaths: []
    )
)
