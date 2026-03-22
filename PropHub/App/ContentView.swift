import SwiftUI

/// Root navigation view that switches between authentication flow and main app content.
/// Uses the authentication state to determine which view hierarchy to present.
struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Group {
            switch authManager.authState {
            case .idle, .loading:
                LaunchScreenView()
            case .unauthenticated:
                AuthView()
            case .authenticated:
                if themeManager.activeProject == nil {
                    DemoSwitcherView()
                } else {
                    MainTabView()
                }
            case .unauthorized:
                UnauthorizedView()
            case .error(let message):
                ErrorStateView(
                    message: message,
                    retryAction: {
                        Task {
                            await authManager.signOut()
                        }
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authManager.authState)
    }
}

/// Displayed while the app is determining authentication state.
struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "building.2.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                Text("PropHub")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                ProgressView()
                    .padding(.top, 8)
            }
        }
    }
}

/// Shown when the user's Google account is not whitelisted.
struct UnauthorizedView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)
            Text(NSLocalizedString("unauthorized_title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            Text(NSLocalizedString("unauthorized_message", comment: ""))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                Task { await authManager.signOut() }
            } label: {
                Text(NSLocalizedString("sign_out", comment: ""))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.horizontal, 48)
        }
        .accessibilityElement(children: .contain)
    }
}

/// Generic error state view with retry capability.
struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.orange)
            Text(NSLocalizedString("error_title", comment: ""))
                .font(.title2)
                .fontWeight(.bold)
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button(action: retryAction) {
                Text(NSLocalizedString("try_again", comment: ""))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 48)
        }
    }
}

/// Main tab-based navigation for authenticated users with an active demo project.
struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_dashboard", comment: ""),
                        systemImage: "house.fill"
                    )
                }
                .accessibilityLabel(NSLocalizedString("tab_dashboard", comment: ""))

            UnitListView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_units", comment: ""),
                        systemImage: "building.2.fill"
                    )
                }
                .accessibilityLabel(NSLocalizedString("tab_units", comment: ""))

            ChatView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_chat", comment: ""),
                        systemImage: "bubble.left.and.bubble.right.fill"
                    )
                }
                .accessibilityLabel(NSLocalizedString("tab_chat", comment: ""))

            NewLaunchesView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_launches", comment: ""),
                        systemImage: "sparkles"
                    )
                }
                .accessibilityLabel(NSLocalizedString("tab_launches", comment: ""))

            SettingsView()
                .tabItem {
                    Label(
                        NSLocalizedString("tab_settings", comment: ""),
                        systemImage: "gearshape.fill"
                    )
                }
                .accessibilityLabel(NSLocalizedString("tab_settings", comment: ""))
        }
        .tint(themeManager.primaryColor)
    }
}
