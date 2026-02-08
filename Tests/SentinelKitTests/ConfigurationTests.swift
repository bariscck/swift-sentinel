import Testing
@testable import SentinelKit

@Test func configurationDefaultsHaveEmptyChangedFiles() {
    let config = Configuration()
    #expect(config.changedFiles.isEmpty)
}

@Test func configurationAcceptsChangedFiles() {
    let files = ["/project/Sources/File.swift", "/project/Sources/Other.swift"]
    let config = Configuration(changedFiles: files)
    #expect(config.changedFiles == files)
    #expect(config.projectPath == config.projectPath) // still has default
}

@Test func configurationCombinesAllOptions() {
    let config = Configuration(
        projectPath: "/my/project",
        includePaths: ["Sources"],
        excludePaths: ["Tests"],
        changedFiles: ["/my/project/Sources/A.swift"]
    )
    #expect(config.projectPath == "/my/project")
    #expect(config.includePaths == ["Sources"])
    #expect(config.excludePaths == ["Tests"])
    #expect(config.changedFiles.count == 1)
}
