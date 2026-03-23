import SwiftUI

/// Root navigation view — switches between auth and main app content.
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
                    retryAction: { Task { await authManager.signOut() } }
                )
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authManager.authState)
    }
}

/// Premium launch screen with navy/gold branding.
struct LaunchScreenView: View {
    @State private var pulseGold = false

    var body: some View {
        ZStack {
            Color.brandNavy.ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.brandGold.opacity(pulseGold ? 0.15 : 0.05))
                        .frame(width: 140, height: 140)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseGold)

                    Image(systemName: "building.2.fill")
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(.brandGold)
                }

                Text("PROPHUB")
                    .font(.system(size: 28, weight: .light))
                    .tracking(10)
                    .foregroundStyle(.white)

                ProgressView()
                    .tint(.brandGold)
                    .padding(.top, 8)
            }
        }
        .onAppear { pulseGold = true }
    }
}

/// Shown when the user's account is not whitelisted.
struct UnauthorizedView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            Color.brandWhite.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.brandCoral)

                Text("Access Restricted")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.brandCharcoal)

                Text("Your account is not authorized for PropHub. Please contact your administrator.")
                    .font(.body)
                    .foregroundStyle(.brandGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button {
                    Task { await authManager.signOut() }
                } label: {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.brandCoral)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 48)
            }
        }
    }
}

/// Generic error state view.
struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        ZStack {
            Color.brandWhite.ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.brandGold)

                Text("Something went wrong")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.brandCharcoal)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.brandGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button(action: retryAction) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.brandNavy)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 48)
            }
        }
    }
}

/// Premium tab-based navigation.
struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            UnitListView()
                .tabItem {
                    Label("My Units", systemImage: "building.2.fill")
                }

            ChatView()
                .tabItem {
                    Label("Concierge", systemImage: "bubble.left.and.bubble.right.fill")
                }

            NewLaunchesView()
                .tabItem {
                    Label("Launches", systemImage: "sparkles")
                }

            SettingsView()
                .tabItem {
                    Label("More", systemImage: "line.3.horizontal")
                }
        }
        .tint(themeManager.primaryColor)
    }
}
