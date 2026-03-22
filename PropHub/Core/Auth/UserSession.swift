import Foundation

/// Represents the current authenticated user session.
/// Provides access to user profile data and active demo context.
final class UserSession: ObservableObject {
    static let shared = UserSession()

    @Published var currentUser: AuthUser?
    @Published var contactId: String?
    @Published var activeProjectId: String?

    private let secrets = SecretsManager.shared

    private init() {
        loadSession()
    }

    /// Whether the user has an active, authenticated session.
    var isAuthenticated: Bool {
        currentUser != nil && secrets.getString(forKey: SecretsManager.Keys.accessToken) != nil
    }

    /// Stores session data after successful authentication.
    func setSession(user: AuthUser) {
        currentUser = user
        contactId = user.contactId
        persistSession()
    }

    /// Clears all session data on sign-out.
    func clearSession() {
        currentUser = nil
        contactId = nil
        activeProjectId = nil
        secrets.delete(forKey: SecretsManager.Keys.currentUserId)
    }

    /// Sets the active demo project for filtering API calls.
    func setActiveProject(_ projectId: String) {
        activeProjectId = projectId
    }

    // MARK: - Persistence

    private func persistSession() {
        guard let user = currentUser,
              let data = try? JSONEncoder().encode(user) else { return }
        secrets.save(data, forKey: SecretsManager.Keys.currentUserId)
    }

    private func loadSession() {
        guard let data = secrets.load(forKey: SecretsManager.Keys.currentUserId),
              let user = try? JSONDecoder().decode(AuthUser.self, from: data) else { return }
        currentUser = user
        contactId = user.contactId
    }
}
