import Foundation

/// Finds Swift files changed in the current git working tree or relative to a base branch.
struct GitDiffFilesFinder {

    enum GitError: Error, CustomStringConvertible {
        case notAGitRepository
        case gitCommandFailed(String)

        var description: String {
            switch self {
            case .notAGitRepository:
                return "Not a git repository. --changed-only requires a git project."
            case .gitCommandFailed(let message):
                return "Git command failed: \(message)"
            }
        }
    }

    /// Returns absolute paths of changed `.swift` files.
    ///
    /// - Parameters:
    ///   - projectPath: Absolute path to the project root.
    ///   - baseBranch: Optional base branch to diff against (e.g. "main").
    ///                 When nil, reports uncommitted changes (staged + unstaged + untracked).
    /// - Returns: Array of absolute paths to changed Swift files.
    static func changedSwiftFiles(in projectPath: String, baseBranch: String?) throws -> [String] {
        // Verify this is a git repository
        let checkResult = run(command: "git", arguments: ["rev-parse", "--git-dir"], in: projectPath)
        guard checkResult.exitCode == 0 else {
            throw GitError.notAGitRepository
        }

        var changedPaths = Set<String>()

        if let base = baseBranch {
            // Diff against a base branch — shows all commits on current branch
            let result = run(
                command: "git",
                arguments: ["diff", "--name-only", "--diff-filter=ACMR", "\(base)...HEAD"],
                in: projectPath
            )
            if result.exitCode != 0 {
                throw GitError.gitCommandFailed(result.stderr)
            }
            parsePaths(from: result.stdout, into: &changedPaths)
        } else {
            // Uncommitted changes: staged
            let staged = run(
                command: "git",
                arguments: ["diff", "--cached", "--name-only", "--diff-filter=ACMR"],
                in: projectPath
            )
            parsePaths(from: staged.stdout, into: &changedPaths)

            // Uncommitted changes: unstaged modifications
            let unstaged = run(
                command: "git",
                arguments: ["diff", "--name-only", "--diff-filter=ACMR"],
                in: projectPath
            )
            parsePaths(from: unstaged.stdout, into: &changedPaths)

            // Untracked new files
            let untracked = run(
                command: "git",
                arguments: ["ls-files", "--others", "--exclude-standard"],
                in: projectPath
            )
            parsePaths(from: untracked.stdout, into: &changedPaths)
        }

        // Filter to .swift only and resolve to absolute paths
        return changedPaths
            .filter { $0.hasSuffix(".swift") }
            .map { relativePath in
                if relativePath.hasPrefix("/") {
                    return relativePath
                }
                return (projectPath as NSString).appendingPathComponent(relativePath)
            }
            .sorted()
    }

    // MARK: - Private

    private struct CommandResult {
        let stdout: String
        let stderr: String
        let exitCode: Int32
    }

    private static func run(command: String, arguments: [String], in directory: String) -> CommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments
        process.currentDirectoryURL = URL(fileURLWithPath: directory)

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return CommandResult(stdout: "", stderr: error.localizedDescription, exitCode: -1)
        }

        let stdout = String(data: stdoutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let stderr = String(data: stderrPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

        return CommandResult(stdout: stdout, stderr: stderr, exitCode: process.terminationStatus)
    }

    private static func parsePaths(from output: String, into set: inout Set<String>) {
        let lines = output.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                set.insert(trimmed)
            }
        }
    }
}
