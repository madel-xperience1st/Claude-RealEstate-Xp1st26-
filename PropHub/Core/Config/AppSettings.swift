import Foundation
import SwiftUI

/// Global app settings including demo mode toggle.
/// Demo mode uses mock data, bypasses auth, and enables the full app flow without a backend.
@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    /// When true, the app uses MockDataProvider instead of live API calls.
    /// Perfect for presales demos without a configured backend.
    @Published var useMockData: Bool {
        didSet {
            UserDefaults.standard.set(useMockData, forKey: "prophub.useMockData")
        }
    }

    /// When true, bypasses Google OAuth and signs in as a demo user.
    @Published var demoAuthEnabled: Bool {
        didSet {
            UserDefaults.standard.set(demoAuthEnabled, forKey: "prophub.demoAuth")
        }
    }

    private init() {
        // Default to demo mode ON so the app works immediately
        self.useMockData = UserDefaults.standard.object(forKey: "prophub.useMockData") as? Bool ?? true
        self.demoAuthEnabled = UserDefaults.standard.object(forKey: "prophub.demoAuth") as? Bool ?? true
    }
}
