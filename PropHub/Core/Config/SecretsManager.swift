import Foundation
import KeychainAccess

/// Keychain wrapper for secure storage of tokens, credentials, and encrypted data.
/// All sensitive data (JWT tokens, org connections, etc.) must be stored through this manager.
final class SecretsManager {
    static let shared = SecretsManager()

    private let keychain: Keychain

    private init() {
        keychain = Keychain(service: "com.prophub.app")
            .accessibility(.whenUnlockedThisDeviceOnly)
    }

    // MARK: - String Storage

    /// Saves a string value to the Keychain.
    func save(_ value: String, forKey key: String) {
        do {
            try keychain.set(value, key: key)
        } catch {
            print("[PropHub] Keychain save error for \(key): \(error.localizedDescription)")
        }
    }

    /// Retrieves a string value from the Keychain.
    func getString(forKey key: String) -> String? {
        do {
            return try keychain.get(key)
        } catch {
            print("[PropHub] Keychain read error for \(key): \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Data Storage

    /// Saves raw data to the Keychain.
    func save(_ data: Data, forKey key: String) {
        do {
            try keychain.set(data, key: key)
        } catch {
            print("[PropHub] Keychain save error for \(key): \(error.localizedDescription)")
        }
    }

    /// Retrieves raw data from the Keychain.
    func load(forKey key: String) -> Data? {
        do {
            return try keychain.getData(key)
        } catch {
            print("[PropHub] Keychain read error for \(key): \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Deletion

    /// Removes a value from the Keychain.
    func delete(forKey key: String) {
        do {
            try keychain.remove(key)
        } catch {
            print("[PropHub] Keychain delete error for \(key): \(error.localizedDescription)")
        }
    }

    /// Removes all PropHub data from the Keychain.
    func clearAll() {
        do {
            try keychain.removeAll()
        } catch {
            print("[PropHub] Keychain clear error: \(error.localizedDescription)")
        }
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
