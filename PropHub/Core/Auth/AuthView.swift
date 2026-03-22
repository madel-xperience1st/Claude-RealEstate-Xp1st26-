import SwiftUI

/// Login screen for PropHub.
/// Shows branding and a single sign-in button (demo mode).
/// Google SSO can be re-added later.
struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color.blue.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App Logo & Title
                VStack(spacing: 16) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                        .accessibilityHidden(true)

                    Text("PropHub")
                        .font(.system(size: 40, weight: .bold))

                    Text(NSLocalizedString("auth_subtitle", comment: ""))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Sign-In Button
                VStack(spacing: 16) {
                    Button {
                        Task { await authManager.signInWithDemoMode() }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                            Text(NSLocalizedString("enter_demo_mode", comment: ""))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(authManager.isLoading)
                    .padding(.horizontal, 32)
                    .accessibilityLabel(NSLocalizedString("enter_demo_mode", comment: ""))

                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }

                    Text(NSLocalizedString("auth_restricted", comment: ""))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 48)
                }

                Spacer()
                    .frame(height: 60)
            }
        }
    }
}
