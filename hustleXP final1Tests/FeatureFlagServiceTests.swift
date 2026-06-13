import XCTest
@testable import hustleXP_final1

/// Tests for the local-cache-only FeatureFlagService.
/// The service no longer calls the backend (flags router removed);
/// it resolves flags from UserDefaults cache + compiled defaults.
@MainActor
final class FeatureFlagServiceTests: XCTestCase {

    private let cacheKey = "feature_flags_cache"

    /// WORKAROUND (iOS 26.2 simulator runtime): deallocating a @MainActor
    /// ObservableObject inside a sync XCTest method aborts in
    /// swift_task_deinitOnExecutorImpl (TaskLocal::StopLookupScope double-free).
    /// Production only ever uses the never-deallocated singleton, so we retain
    /// test instances for the process lifetime instead of letting them deinit.
    private static var retainedInstances: [FeatureFlagService] = []

    private func makeService() -> FeatureFlagService {
        let service = FeatureFlagService()
        Self.retainedInstances.append(service)
        return service
    }

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: cacheKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        super.tearDown()
    }

    private func seedCache(_ flags: [String: Bool]) {
        let data = try! JSONEncoder().encode(flags)
        UserDefaults.standard.set(data, forKey: cacheKey)
    }

    // MARK: - isEnabled

    func testIsEnabled_defaultsFalse() {
        let sut = makeService()
        // Unset flags default to false
        XCTAssertFalse(sut.isEnabled("nonexistent_flag"))
    }

    // MARK: - Cache loading

    func testInit_loadsFlagsFromCache() {
        seedCache(["dark_mode": true, "beta_feature": false])

        let sut = makeService()

        XCTAssertTrue(sut.isEnabled("dark_mode"))
        XCTAssertFalse(sut.isEnabled("beta_feature"))
    }

    func testInit_corruptCache_fallsBackToEmpty() {
        UserDefaults.standard.set(Data("not json".utf8), forKey: cacheKey)

        let sut = makeService()

        XCTAssertFalse(sut.isEnabled("anything"))
    }

    // MARK: - refreshFlags

    func testRefreshFlags_keepsExistingFlags() async {
        seedCache(["test_flag": true])
        let sut = makeService()
        XCTAssertTrue(sut.isEnabled("test_flag"))

        await sut.refreshFlags()

        // Local refresh must not drop previously loaded flags
        XCTAssertTrue(sut.isEnabled("test_flag"))
    }

    func testRefreshFlags_persistsFlagsToCache() async {
        seedCache(["persisted_flag": true])
        let sut = makeService()

        await sut.refreshFlags()

        // A fresh instance must see the persisted flags
        let second = makeService()
        XCTAssertTrue(second.isEnabled("persisted_flag"))
    }
}
