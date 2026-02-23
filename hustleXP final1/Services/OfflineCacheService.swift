import Foundation

/// Manages offline caching of API responses using UserDefaults-backed storage
@MainActor
final class OfflineCacheService {
    static let shared = OfflineCacheService()

    private let defaults = UserDefaults.standard
    private let cachePrefix = "hx_cache_"
    private let maxAge: TimeInterval = 3600 // 1 hour default TTL

    private init() {}

    // MARK: - Cache Operations

    /// Save data to cache with a key
    func cache<T: Encodable>(_ value: T, forKey key: String, ttl: TimeInterval? = nil) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(value) else { return }

        let entry = CacheEntry(data: data, cachedAt: Date(), ttl: ttl ?? maxAge)
        guard let entryData = try? JSONEncoder().encode(entry) else { return }

        defaults.set(entryData, forKey: cachePrefix + key)
    }

    /// Retrieve cached data for a key
    func retrieve<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let entryData = defaults.data(forKey: cachePrefix + key),
              let entry = try? JSONDecoder().decode(CacheEntry.self, from: entryData) else {
            return nil
        }

        // Check TTL
        if Date().timeIntervalSince(entry.cachedAt) > entry.ttl {
            defaults.removeObject(forKey: cachePrefix + key)
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(T.self, from: entry.data)
    }

    /// Check if a valid cache entry exists
    func hasValidCache(forKey key: String) -> Bool {
        guard let entryData = defaults.data(forKey: cachePrefix + key),
              let entry = try? JSONDecoder().decode(CacheEntry.self, from: entryData) else {
            return false
        }
        return Date().timeIntervalSince(entry.cachedAt) <= entry.ttl
    }

    /// Remove a specific cache entry
    func invalidate(forKey key: String) {
        defaults.removeObject(forKey: cachePrefix + key)
    }

    /// Clear all cached data
    func clearAll() {
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(cachePrefix) {
            defaults.removeObject(forKey: key)
        }
        HXLogger.info("OfflineCacheService: Cleared all cache entries", category: "General")
    }
}

// MARK: - Cache Entry

private struct CacheEntry: Codable {
    let data: Data
    let cachedAt: Date
    let ttl: TimeInterval
}
