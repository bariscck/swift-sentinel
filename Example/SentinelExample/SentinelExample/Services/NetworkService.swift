import Foundation

// VIOLATION: Service class not marked final
class NetworkService {
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
final class AuthService {
    private let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func login(email: String, password: String) async throws -> Bool {
        return true
    }
}
