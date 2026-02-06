import Foundation

// VIOLATION: Service class not marked final
class StorageService {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(key: String, data: Data) {
        defaults.set(data, forKey: key)
    }

    func load(key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func delete(key: String) {
        defaults.removeObject(forKey: key)
    }
}
