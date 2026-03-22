import Foundation

/// Typed error hierarchy for all API operations.
/// Provides user-facing localized descriptions for each error case.
enum APIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(Int)
    case networkError(String)
    case decodingError(String)
    case noData
    case tokenExpired
    case offlineNoCache

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("error_invalid_url", comment: "")
        case .invalidResponse:
            return NSLocalizedString("error_invalid_response", comment: "")
        case .unauthorized:
            return NSLocalizedString("error_unauthorized", comment: "")
        case .forbidden:
            return NSLocalizedString("error_forbidden", comment: "")
        case .notFound:
            return NSLocalizedString("error_not_found", comment: "")
        case .rateLimited:
            return NSLocalizedString("error_rate_limited", comment: "")
        case .serverError(let code):
            return String(format: NSLocalizedString("error_server", comment: ""), code)
        case .networkError(let message):
            return message
        case .decodingError(let detail):
            return String(format: NSLocalizedString("error_decoding", comment: ""), detail)
        case .noData:
            return NSLocalizedString("error_no_data", comment: "")
        case .tokenExpired:
            return NSLocalizedString("error_token_expired", comment: "")
        case .offlineNoCache:
            return NSLocalizedString("error_offline", comment: "")
        }
    }

    /// Whether the error indicates the user should re-authenticate.
    var requiresReauth: Bool {
        switch self {
        case .unauthorized, .tokenExpired:
            return true
        default:
            return false
        }
    }
}
