extension Array where Element: SourceCodeProviding {
    public func inFile(named fileName: String) -> [Element] {
        filter { $0.sourceCodeLocation.sourceFilePath?.lastPathComponent == fileName }
    }

    public func inFilePath(containing substring: String) -> [Element] {
        filter { $0.sourceCodeLocation.filePath.contains(substring) }
    }
}
