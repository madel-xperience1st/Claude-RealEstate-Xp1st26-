import Foundation

/// Centralized non-secret application configuration.
/// Reads values from AppConfig.plist with fallback defaults.
enum AppConfig {
    private static let configDict: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "AppConfig", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            return [:]
        }
        return dict
    }()

    /// Default MuleSoft API base URL for the primary org.
    static var defaultMuleBaseURL: String {
        configDict["MuleBaseURL"] as? String ?? "https://prophub-exp-api.cloudhub.io/api/v1"
    }

    /// Default Salesforce Org ID.
    static var defaultOrgId: String {
        configDict["DefaultOrgId"] as? String ?? ""
    }

    /// Google OAuth client ID for iOS.
    static var googleClientID: String {
        configDict["GoogleClientID"] as? String ?? ""
    }

    /// Cache time-to-live in seconds (default: 15 minutes).
    static var cacheTTLSeconds: TimeInterval {
        configDict["CacheTTLSeconds"] as? TimeInterval ?? 900
    }

    /// API request timeout in seconds.
    static var requestTimeoutSeconds: TimeInterval {
        configDict["RequestTimeoutSeconds"] as? TimeInterval ?? 30
    }

    /// Maximum number of retry attempts for failed requests.
    static var maxRetryAttempts: Int {
        configDict["MaxRetryAttempts"] as? Int ?? 3
    }

    /// App version string from the bundle.
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    /// Build number string from the bundle.
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
