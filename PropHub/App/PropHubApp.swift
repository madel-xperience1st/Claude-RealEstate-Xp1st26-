import SwiftUI

/// Main entry point for the PropHub application.
@main
struct PropHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var environment = Environment.shared
    @StateObject private var router = AppRouter.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .environmentObject(environment)
                .environmentObject(router)
        }
    }
}
