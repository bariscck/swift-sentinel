import Testing
import Foundation
@testable import SentinelCore

@Test func scopeBuilderWithoutChangedFilesReturnsAll() throws {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent("sentinel-test-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: tempDir) }

    // Create two Swift files
    let file1 = tempDir.appendingPathComponent("FileA.swift")
    let file2 = tempDir.appendingPathComponent("FileB.swift")
    try "class Alpha {}".write(to: file1, atomically: true, encoding: .utf8)
    try "class Beta {}".write(to: file2, atomically: true, encoding: .utf8)

    let scope = SentinelScopeBuilder(path: tempDir.path)
    SentinelScopeBuilder.resetCache()

    let classes = scope.classes()
    #expect(classes.count == 2)
}

@Test func scopeBuilderWithChangedFilesFiltersCorrectly() throws {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent("sentinel-test-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: tempDir) }

    // Create two Swift files
    let file1 = tempDir.appendingPathComponent("FileA.swift")
    let file2 = tempDir.appendingPathComponent("FileB.swift")
    try "class Alpha {}".write(to: file1, atomically: true, encoding: .utf8)
    try "class Beta {}".write(to: file2, atomically: true, encoding: .utf8)

    // Only include file1 as a "changed" file
    let scope = SentinelScopeBuilder(
        path: tempDir.path,
        changedFiles: [file1.path]
    )
    SentinelScopeBuilder.resetCache()

    let classes = scope.classes()
    #expect(classes.count == 1)
    #expect(classes[0].name == "Alpha")
}

@Test func scopeBuilderWithEmptyChangedFilesReturnsAll() throws {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent("sentinel-test-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: tempDir) }

    let file1 = tempDir.appendingPathComponent("FileA.swift")
    try "class Gamma {}".write(to: file1, atomically: true, encoding: .utf8)

    // Empty changedFiles means "lint everything"
    let scope = SentinelScopeBuilder(path: tempDir.path, changedFiles: [])
    SentinelScopeBuilder.resetCache()

    let classes = scope.classes()
    #expect(classes.count == 1)
}

@Test func scopeBuilderChangedFilesPreservedThroughCopy() throws {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent("sentinel-test-\(UUID().uuidString)")
    let subDir = tempDir.appendingPathComponent("Sources")
    try FileManager.default.createDirectory(at: subDir, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: tempDir) }

    let file1 = subDir.appendingPathComponent("FileA.swift")
    let file2 = subDir.appendingPathComponent("FileB.swift")
    try "class Alpha {}".write(to: file1, atomically: true, encoding: .utf8)
    try "class Beta {}".write(to: file2, atomically: true, encoding: .utf8)

    // Create scope with changedFiles, then chain with .on() which triggers copy()
    let scope = SentinelScopeBuilder(
        path: tempDir.path,
        changedFiles: [file1.path]
    )
    SentinelScopeBuilder.resetCache()

    let narrowedScope = scope.on("Sources")
    let classes = narrowedScope.classes()
    #expect(classes.count == 1)
    #expect(classes[0].name == "Alpha")
}
