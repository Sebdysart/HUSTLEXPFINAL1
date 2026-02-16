import Foundation
import Security

/// Manages secure storage of sensitive data in the iOS Keychain
///
/// Use this for storing authentication tokens, API keys, and other
/// credentials that should persist securely across app launches.
final class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    // MARK: - Save

    /// Saves a string value to the Keychain
    /// - Parameters:
    ///   - value: The string value to store
    ///   - key: The key to store it under
    func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else {
            HXLogger.error("Keychain: Failed to convert value to data for key: \(key)", category: "Auth")
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            HXLogger.debug("Keychain: Saved value for key: \(key)", category: "Auth")
        } else {
            HXLogger.error("Keychain: Failed to save value for key: \(key), status: \(status)", category: "Auth")
        }
    }

    // MARK: - Get

    /// Retrieves a string value from the Keychain
    /// - Parameter key: The key to retrieve
    /// - Returns: The stored string value, or nil if not found
    func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            if let data = result as? Data,
               let value = String(data: data, encoding: .utf8) {
                HXLogger.debug("Keychain: Retrieved value for key: \(key)", category: "Auth")
                return value
            }
        } else if status == errSecItemNotFound {
            HXLogger.debug("Keychain: No value found for key: \(key)", category: "Auth")
        } else {
            HXLogger.error("Keychain: Failed to retrieve value for key: \(key), status: \(status)", category: "Auth")
        }

        return nil
    }

    // MARK: - Delete

    /// Deletes a value from the Keychain
    /// - Parameter key: The key to delete
    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess {
            HXLogger.debug("Keychain: Deleted value for key: \(key)", category: "Auth")
        } else if status == errSecItemNotFound {
            HXLogger.debug("Keychain: No value to delete for key: \(key)", category: "Auth")
        } else {
            HXLogger.error("Keychain: Failed to delete value for key: \(key), status: \(status)", category: "Auth")
        }
    }

    // MARK: - Clear All

    /// Clears all keychain items stored by this app
    /// Use with caution - this will delete all stored credentials
    func clearAll() {
        let secClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]

        for secClass in secClasses {
            let query: [String: Any] = [kSecClass as String: secClass]
            SecItemDelete(query as CFDictionary)
        }

        HXLogger.debug("Keychain: Cleared all items", category: "Auth")
    }
}

// MARK: - Common Keys

extension KeychainManager {
    /// Common keychain keys used throughout the app
    enum Key {
        static let authToken = "authToken"
        static let refreshToken = "refreshToken"
        static let userId = "userId"
        static let firebaseUid = "firebaseUid"
    }
}
