import Foundation

// VIOLATION: Protocol name doesn't end with a descriptive suffix
protocol DataFetcher {
    func fetchAll() async throws -> Data
    func fetchById(_ id: String) async throws -> Data
}

// OK: Ends with "able"
protocol Cacheable {
    var cacheKey: String { get }
    var cacheExpiry: TimeInterval { get }
}

// VIOLATION: Protocol name doesn't end with a descriptive suffix
protocol Router {
    func navigate(to destination: String)
    func pop()
}
