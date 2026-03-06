import Foundation
import Combine

/// Feature flag service - fetches flags from backend, caches locally
@MainActor
final class FeatureFlagService: ObservableObject {
    static let shared = FeatureFlagService()

    @Published private(set) var flags: [String: Bool] = [:]
    private let trpc: TRPCClientProtocol
    private let cacheKey = "feature_flags_cache"

    init(client: TRPCClientProtocol = TRPCClient.shared) {
        self.trpc = client
        loadCachedFlags()
    }

    /// Check if a feature flag is enabled
    func isEnabled(_ flagName: String) -> Bool {
        flags[flagName] ?? false
    }

    /// Fetch flags from backend
    func refreshFlags() async {
        struct EmptyInput: Codable {}
        struct FlagResponse: Codable {
            let name: String
            let enabled: Bool
        }

        do {
            let result: [FlagResponse] = try await trpc.call(
                router: "flags",
                procedure: "getFlags",
                type: .query,
                input: EmptyInput()
            )
            var newFlags: [String: Bool] = [:]
            for flag in result {
                newFlags[flag.name] = flag.enabled
            }
            self.flags = newFlags
            saveFlagsToCache(newFlags)
        } catch {
            HXLogger.error("FeatureFlagService: Failed to fetch flags - \(error)", category: "General")
        }
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
