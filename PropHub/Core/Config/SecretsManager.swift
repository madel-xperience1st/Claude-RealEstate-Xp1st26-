import Foundation
import Security

/// Keychain wrapper for secure storage of tokens, credentials, and encrypted data.
/// All sensitive data (JWT tokens, org connections, etc.) must be stored through this manager.
final class SecretsManager {
    static let shared = SecretsManager()

    private let service = "com.prophub.app"

    private init() {}

    // MARK: - String Storage

    /// Saves a string value to the Keychain.
    func save(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        save(data, forKey: key)
    }

    /// Retrieves a string value from the Keychain.
    func getString(forKey key: String) -> String? {
        guard let data = load(forKey: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Data Storage

    /// Saves raw data to the Keychain.
    func save(_ data: Data, forKey key: String) {
        delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("[PropHub] Keychain save error for \(key): \(status)")
        }
    }

    /// Retrieves raw data from the Keychain.
    func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    // MARK: - Deletion

    /// Removes a value from the Keychain.
    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// Removes all PropHub data from the Keychain.
    func clearAll() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Well-Known Keys

extension SecretsManager {
    enum Keys {
        static let accessToken = "prophub.access.token"
        static let refreshToken = "prophub.refresh.token"
        static let tokenExpiry = "prophub.token.expiry"
        static let googleIdToken = "prophub.google.id.token"
        static let fcmToken = "prophub.fcm.token"
        static let currentUserId = "prophub.current.user.id"
    }
}
