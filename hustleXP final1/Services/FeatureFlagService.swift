import Foundation
import Combine

/// Feature flag service - currently cache and defaults only until a live flags router exists again.
@MainActor
final class FeatureFlagService: ObservableObject {
    static let shared = FeatureFlagService()

    @Published private(set) var flags: [String: Bool] = [:]
    private let cacheKey = "feature_flags_cache"
    private let defaultFlags: [String: Bool] = [:]

    init() {
        loadCachedFlags()
    }

    /// Check if a feature flag is enabled
    func isEnabled(_ flagName: String) -> Bool {
        flags[flagName] ?? false
    }

    /// Refreshes feature flags from the best local source available.
    func refreshFlags() async {
        let resolvedFlags = flags.isEmpty ? defaultFlags : flags
        self.flags = resolvedFlags
        saveFlagsToCache(resolvedFlags)
        HXLogger.info("FeatureFlagService: Using local cache/defaults while backend flags router is unavailable", category: "General")
    }

    private func loadCachedFlags() {
        if let data = UserDefaults.standard.data(forKey: cacheKey),
           let cached = try? JSONDecoder().decode([String: Bool].self, from: data) {
            self.flags = cached
        }
    }

    private func saveFlagsToCache(_ flags: [String: Bool]) {
        if let data = try? JSONEncoder().encode(flags) {
            UserDefaults.standard.set(data, forKey: cacheKey)
        }
    }
}
