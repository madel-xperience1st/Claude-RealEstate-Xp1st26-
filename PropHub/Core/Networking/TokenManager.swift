import Foundation

/// Manages OAuth token lifecycle including storage, validation, and refresh.
/// Tokens are stored in the Keychain and automatically refreshed before expiry.
actor TokenManager {
    static let shared = TokenManager()

    private let secrets = SecretsManager.shared
    private var isRefreshing = false
    private var refreshContinuations: [CheckedContinuation<String, Error>] = []

    /// Returns a valid access token, refreshing if necessary.
    /// If the token is within 60 seconds of expiry, triggers a refresh.
    func validToken() async throws -> String {
        guard let token = secrets.getString(forKey: SecretsManager.Keys.accessToken) else {
            throw APIError.unauthorized
        }

        if isTokenExpiringSoon() {
            return try await refreshToken()
        }

        return token
    }

    /// Stores a new token pair received from the auth endpoint.
    func storeTokens(accessToken: String, refreshToken: String?, expiresIn: Int) {
        secrets.save(accessToken, forKey: SecretsManager.Keys.accessToken)
        if let refreshToken = refreshToken {
            secrets.save(refreshToken, forKey: SecretsManager.Keys.refreshToken)
        }
        let expiry = Date().addingTimeInterval(TimeInterval(expiresIn))
        secrets.save(
            String(expiry.timeIntervalSince1970),
            forKey: SecretsManager.Keys.tokenExpiry
        )
    }

    /// Refreshes the access token using the stored refresh token.
    /// Coalesces concurrent refresh requests to avoid duplicate calls.
    @discardableResult
    func refreshToken() async throws -> String {
        if isRefreshing {
            return try await withCheckedThrowingContinuation { continuation in
                refreshContinuations.append(continuation)
            }
        }

        isRefreshing = true

        do {
            guard let refreshToken = secrets.getString(forKey: SecretsManager.Keys.refreshToken) else {
                throw APIError.tokenExpired
            }

            let baseURL = await MainActor.run { Environment.shared.muleBaseURL }
            let url = URL(string: baseURL + "/auth/refresh")
            guard let url = url else { throw APIError.invalidURL }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.tokenExpired
            }

            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            storeTokens(
                accessToken: tokenResponse.accessToken,
                refreshToken: nil,
                expiresIn: tokenResponse.expiresIn
            )

            isRefreshing = false
            let token = tokenResponse.accessToken
            for continuation in refreshContinuations {
                continuation.resume(returning: token)
            }
            refreshContinuations.removeAll()

            return token
        } catch {
            isRefreshing = false
            for continuation in refreshContinuations {
                continuation.resume(throwing: error)
            }
            refreshContinuations.removeAll()
            throw error
        }
    }

    /// Clears all stored tokens. Called on sign-out.
    func clearTokens() {
        secrets.delete(forKey: SecretsManager.Keys.accessToken)
        secrets.delete(forKey: SecretsManager.Keys.refreshToken)
        secrets.delete(forKey: SecretsManager.Keys.tokenExpiry)
    }

    // MARK: - Private

    private func isTokenExpiringSoon() -> Bool {
        guard let expiryString = secrets.getString(forKey: SecretsManager.Keys.tokenExpiry),
              let expiryTimestamp = Double(expiryString) else {
            return true
        }
        let expiry = Date(timeIntervalSince1970: expiryTimestamp)
        return expiry.timeIntervalSinceNow < 60
    }
}

/// Response model for token endpoints.
struct TokenResponse: Decodable {
    let accessToken: String
    let expiresIn: Int
    let user: AuthUser?
}

/// Authenticated user profile returned from the auth endpoint.
struct AuthUser: Codable {
    let id: String
    let email: String
    let displayName: String
    let role: String?
    let contactId: String?
}
