import SwiftUI

/// Login screen presenting Google Sign-In for presales users.
/// Shows the PropHub branding, Google SSO button, and a Demo Mode option.
struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var settings = AppSettings.shared

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

                // Sign-In Buttons
                VStack(spacing: 16) {
                    // Demo Mode Button (primary for presales)
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

                    // Google Sign-In Button
                    Button {
                        Task { await authManager.signInWithGoogle() }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "person.badge.key.fill")
                                .font(.title3)
                            Text(NSLocalizedString("sign_in_google", comment: ""))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .buttonStyle(.bordered)
                    .disabled(authManager.isLoading)
                    .padding(.horizontal, 32)
                    .accessibilityLabel(NSLocalizedString("sign_in_google", comment: ""))

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
