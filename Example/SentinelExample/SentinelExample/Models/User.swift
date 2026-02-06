import Foundation

struct User: Codable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var avatarURL: URL?
}

struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    var isAvailable: Bool
}

enum AppError {
    case network(Error)
    case parsing(String)
    case unauthorized
    case unknown
}
