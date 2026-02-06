import Foundation

public struct GetFiles: Sendable {
    private let path: String
    private let folder: String?
    private let includes: [String]
    private let excludes: [String]

    public init(path: String, folder: String? = nil, includes: [String] = [], excludes: [String] = []) {
        self.path = path
        self.folder = folder
        self.includes = includes
        self.excludes = excludes
    }

    public func swiftFiles() -> [URL] {
        let baseURL: URL
        if let folder = folder {
            let fullPath = (path as NSString).appendingPathComponent(folder)
            if FileManager.default.fileExists(atPath: fullPath) {
                baseURL = URL(fileURLWithPath: fullPath)
            } else {
                // Try to find the folder within subdirectories
                baseURL = findFolder(named: folder, in: URL(fileURLWithPath: path)) ?? URL(fileURLWithPath: fullPath)
            }
        } else {
            baseURL = URL(fileURLWithPath: path)
        }

        guard FileManager.default.fileExists(atPath: baseURL.path) else {
            return []
        }

        return enumerateSwiftFiles(in: baseURL)
    }

    private func enumerateSwiftFiles(in directory: URL) -> [URL] {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var files: [URL] = []
        for case let fileURL as URL in enumerator {
            guard fileURL.pathExtension == "swift" else { continue }
            guard !isExcluded(fileURL) else { continue }
            if !includes.isEmpty {
                guard isIncluded(fileURL) else { continue }
            }
            files.append(fileURL)
        }
        return files
    }

    private func isExcluded(_ url: URL) -> Bool {
        let path = url.path
        return excludes.contains { pattern in
            if pattern.hasSuffix("*") {
                let prefix = String(pattern.dropLast())
                return url.lastPathComponent.hasPrefix(prefix)
            }
            return path.contains("/\(pattern)/") || path.contains("/\(pattern)")
        }
    }

    private func isIncluded(_ url: URL) -> Bool {
        let path = url.path
        return includes.contains { pattern in
            if pattern.hasSuffix("*") {
                let prefix = String(pattern.dropLast())
                return url.lastPathComponent.hasPrefix(prefix)
            }
            return path.contains("/\(pattern)/") || path.contains("/\(pattern)")
        }
    }

    private func findFolder(named name: String, in directory: URL) -> URL? {
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        for case let dirURL as URL in enumerator {
            var isDir: ObjCBool = false
            if fileManager.fileExists(atPath: dirURL.path, isDirectory: &isDir),
               isDir.boolValue,
               dirURL.lastPathComponent == name {
                return dirURL
            }
        }
        return nil
    }
}
