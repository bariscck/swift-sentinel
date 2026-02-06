import SentinelKit

SentinelRunner.run(
    rules: [
        // ViewModel conventions
        ViewModelMainActorRule(),
        ViewModelInheritanceRule(),

        // Code safety
        NoForceUnwrapRule(),

        // Architecture
        ServiceFinalRule(),

        // Naming
        ProtocolNamingRule(),
    ],
    configuration: Configuration(
        projectPath: "../SentinelExample",
        excludePaths: []
    )
)
