import Foundation
import GoogleSignIn
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

/// Manages the Google OAuth 2.0 authentication flow and MuleSoft token exchange.
/// Validates the user against the Salesforce presales whitelist via MuleSoft.
@MainActor
final class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var authState: AuthState = .idle
    @Published var isLoading = false

    private let tokenManager = TokenManager.shared
    private let userSession = UserSession.shared
    private let environment = Environment.shared

    private init() {
        Task {
            await checkExistingSession()
        }
    }

    /// Initiates the Google Sign-In flow from the given presenting view controller.
    func signInWithGoogle() async {
        authState = .loading
        isLoading = true

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            authState = .error(NSLocalizedString("error_no_root_vc", comment: ""))
            isLoading = false
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                authState = .error(NSLocalizedString("error_no_google_token", comment: ""))
                isLoading = false
                return
            }

            await exchangeTokenWithMuleSoft(googleIdToken: idToken)
        } catch {
            if (error as NSError).code == GIDSignInError.canceled.rawValue {
                authState = .unauthenticated
            } else {
                authState = .error(error.localizedDescription)
            }
            isLoading = false
        }
    }

    /// Signs out the user, clears tokens, and resets state.
    func signOut() async {
        GIDSignIn.sharedInstance.signOut()
        await tokenManager.clearTokens()
        userSession.clearSession()
        CacheManager.shared.clearAll()
        ThemeManager.shared.reset()
        authState = .unauthenticated
    }

    // MARK: - Private

    /// Exchanges the Google ID token with MuleSoft for a PropHub JWT.
    private func exchangeTokenWithMuleSoft(googleIdToken: String) async {
        do {
            let response: TokenResponse = try await APIService.shared.request(
                .authToken(googleIdToken: googleIdToken, orgId: environment.activeConnection.orgId)
            )

            await tokenManager.storeTokens(
                accessToken: response.accessToken,
                refreshToken: nil,
                expiresIn: response.expiresIn
            )

            if let user = response.user {
                userSession.setSession(user: user)
            }

            authState = .authenticated
        } catch let error as APIError {
            switch error {
            case .forbidden:
                authState = .unauthorized
            default:
                authState = .error(error.localizedDescription ?? NSLocalizedString("error_auth_failed", comment: ""))
            }
        } catch {
            authState = .error(error.localizedDescription)
        }

        isLoading = false
    }

    /// Checks if there is an existing valid session on app launch.
    private func checkExistingSession() async {
        guard userSession.isAuthenticated else {
            authState = .unauthenticated
            return
        }

        do {
            _ = try await tokenManager.validToken()
            authState = .authenticated
        } catch {
            authState = .unauthenticated
        }
    }
}
