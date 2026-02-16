//
//  KeychainManagerTests.swift
//  hustleXP final1Tests
//
//  Tests for the KeychainManager secure storage wrapper.
//  Uses unique keys per test to avoid cross-test contamination.
//

import XCTest
@testable import hustleXP_final1

final class KeychainManagerTests: XCTestCase {

    private let keychain = KeychainManager.shared

    /// Unique key prefix to avoid colliding with real app data
    private let testPrefix = "hx_test_\(UUID().uuidString.prefix(8))_"

    override func tearDown() {
        super.tearDown()
        // Clean up any test keys
        for suffix in ["save", "delete", "missing", "overwrite"] {
            keychain.delete(forKey: testPrefix + suffix)
        }
    }

    // MARK: - Save & Retrieve

    func testSaveAndRetrieve() {
        let key = testPrefix + "save"
        let value = "test-token-12345"

        keychain.save(value, forKey: key)
        let retrieved = keychain.get(forKey: key)

        XCTAssertEqual(retrieved, value, "Retrieved value should match saved value")
    }

    // MARK: - Delete

    func testDeleteRemovesValue() {
        let key = testPrefix + "delete"
        keychain.save("to-be-deleted", forKey: key)

        // Verify it was saved
        XCTAssertNotNil(keychain.get(forKey: key))

        // Delete
        keychain.delete(forKey: key)

        // Verify it was removed
        XCTAssertNil(keychain.get(forKey: key), "Deleted key should return nil")
    }

    // MARK: - Non-existent Key

    func testRetrievingNonExistentKeyReturnsNil() {
        let key = testPrefix + "missing"
        let result = keychain.get(forKey: key)
        XCTAssertNil(result, "Non-existent key should return nil")
    }

    // MARK: - Overwrite

    func testOverwriteUpdatesValue() {
        let key = testPrefix + "overwrite"

        keychain.save("original-value", forKey: key)
        XCTAssertEqual(keychain.get(forKey: key), "original-value")

        keychain.save("updated-value", forKey: key)
        XCTAssertEqual(keychain.get(forKey: key), "updated-value",
                        "Save with same key should overwrite the previous value")
    }

    // MARK: - Common Keys

    func testCommonKeysAreDefined() {
        // Verify the key constants exist and are non-empty
        XCTAssertFalse(KeychainManager.Key.authToken.isEmpty)
        XCTAssertFalse(KeychainManager.Key.refreshToken.isEmpty)
        XCTAssertFalse(KeychainManager.Key.userId.isEmpty)
        XCTAssertFalse(KeychainManager.Key.firebaseUid.isEmpty)
    }
}
