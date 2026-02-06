/// Builder protocol for specifying a folder to analyze.
public protocol On {
    func on(_ folder: String) -> Excluding
}
