import Foundation

protocol StorageProtocol {
    func save(key: String, data: Data) throws
    func load(key: String) throws -> Data?
    func delete(key: String) throws
}

final class UserDefaultsStorage: StorageProtocol {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(key: String, data: Data) throws {
        defaults.set(data, forKey: key)
    }

    func load(key: String) throws -> Data? {
        defaults.data(forKey: key)
    }

    func delete(key: String) throws {
        defaults.removeObject(forKey: key)
    }
}
