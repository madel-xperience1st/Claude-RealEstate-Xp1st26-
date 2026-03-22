import SwiftUI
import FirebaseCore
import GoogleSignIn

/// Main entry point for the PropHub application.
/// Configures Firebase, Google Sign-In, and sets up the root view hierarchy.
@main
struct PropHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var environment = Environment.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .environmentObject(environment)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
