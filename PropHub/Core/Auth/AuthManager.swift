import Foundation
import SwiftUI

/// Authentication state machine for the application.
enum AuthState: Equatable {
    case idle
    case loading
    case authenticated
    case unauthenticated
    case unauthorized
    case error(String)
}

/// Simplified auth manager using a single hardcoded demo user.
/// Firebase/Google Sign-In can be added back later.
@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var authState: AuthState = .idle
    @Published var isLoading = false

    private let userSession = UserSession.shared

    private init() {
        Task {
            await checkExistingSession()
        }
    }

    /// Signs in using the hardcoded demo user.
    func signInWithDemoMode() async {
        authState = .loading
        isLoading = true

        // Brief delay for UI transition
        try? await Task.sleep(nanoseconds: 500_000_000)

        let mockUser = MockDataProvider.mockUser
        userSession.setSession(user: mockUser)
        authState = .authenticated
        isLoading = false
    }

    /// Signs in (uses demo mode for now — Google Sign-In disabled).
    func signInWithGoogle() async {
        await signInWithDemoMode()
    }

    /// Signs out the user and resets state.
    func signOut() async {
        userSession.clearSession()
        CacheManager.shared.clearAll()
        ThemeManager.shared.reset()
        authState = .unauthenticated
    }

    // MARK: - Private

    private func checkExistingSession() async {
        if userSession.currentUser != nil {
            authState = .authenticated
        } else {
            authState = .unauthenticated
        }
    }
}
