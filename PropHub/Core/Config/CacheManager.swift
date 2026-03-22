import Foundation

/// In-memory cache with configurable TTL for offline access to recently viewed data.
/// Automatically evicts expired entries on access.
final class CacheManager {
    static let shared = CacheManager()

    private var cache: [String: CacheEntry] = [:]
    private let queue = DispatchQueue(label: "com.prophub.cache", attributes: .concurrent)
    private let ttl: TimeInterval

    private struct CacheEntry {
        let data: Data
        let timestamp: Date

        var isExpired: Bool {
            Date().timeIntervalSince(timestamp) > CacheManager.shared.ttl
        }
    }

    private init() {
        self.ttl = AppConfig.cacheTTLSeconds
    }

    /// Stores a Codable value in the cache with the current timestamp.
    func store<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        queue.async(flags: .barrier) {
            self.cache[key] = CacheEntry(data: data, timestamp: Date())
        }
    }

    /// Stores a type-erased Encodable value in the cache.
    func storeEncodable(_ value: any Encodable, forKey key: String) {
        func encode<T: Encodable>(_ v: T) -> Data? { try? JSONEncoder().encode(v) }
        guard let data = encode(value) else { return }
        queue.async(flags: .barrier) {
            self.cache[key] = CacheEntry(data: data, timestamp: Date())
        }
    }

    /// Retrieves a cached value if it exists and has not expired.
    func retrieve<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        var result: T?
        queue.sync {
            guard let entry = cache[key], !entry.isExpired else {
                return
            }
            result = try? JSONDecoder().decode(type, from: entry.data)
        }
        return result
    }

    /// Removes a specific entry from the cache.
    func remove(forKey key: String) {
        queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: key)
        }
    }

    /// Clears all cached data. Called when switching orgs or demo projects.
    func clearAll() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }

    /// Removes all expired entries from the cache.
    func evictExpired() {
        queue.async(flags: .barrier) {
            self.cache = self.cache.filter { !$0.value.isExpired }
        }
    }
}
