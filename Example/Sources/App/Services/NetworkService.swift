import Foundation

// VIOLATION: Public class not marked final
public class NetworkService {
    var baseURL: URL! = nil // VIOLATION: Force unwrap
    private var session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetch(endpoint: String) async throws -> Data {
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await session.data(from: url)
        return data
    }
}

// OK: Marked final
public final class AuthService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func login(email: String, password: String) async throws -> Bool {
        return true
    }
}

// VIOLATION: Public class not marked final
public class CacheService {
    private var cache: [String: Any] = [:]

    func get(key: String) -> Any? {
        cache[key]
    }

    func set(key: String, value: Any) {
        cache[key] = value
    }
}
