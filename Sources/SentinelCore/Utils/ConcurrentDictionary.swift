import Foundation

final class ConcurrentDictionary<Key: Hashable, Value>: @unchecked Sendable {
    private var dictionary: [Key: Value] = [:]
    private let lock = NSLock()

    subscript(key: Key) -> Value? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return dictionary[key]
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            dictionary[key] = newValue
        }
    }

    func getOrSet(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        if let existing = dictionary[key] {
            return existing
        }
        let value = defaultValue()
        dictionary[key] = value
        return value
    }

    var values: [Value] {
        lock.lock()
        defer { lock.unlock() }
        return Array(dictionary.values)
    }

    var keys: [Key] {
        lock.lock()
        defer { lock.unlock() }
        return Array(dictionary.keys)
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return dictionary.count
    }

    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        dictionary.removeAll()
    }
}
