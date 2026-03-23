import SwiftUI

/// Premium login screen for PropHub — Emaar-inspired luxury design.
struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var animateGold = false

    var body: some View {
        ZStack {
            Color.brandNavy.ignoresSafeArea()

            Circle()
                .fill(Color.brandGold.opacity(0.06))
                .frame(width: 500, height: 500)
                .offset(x: 150, y: -200)
            Circle()
                .fill(Color.brandGold.opacity(0.04))
                .frame(width: 400, height: 400)
                .offset(x: -180, y: 300)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.brandGold, Color(hex: "E8D48B"), .brandGold],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 110, height: 110)
                            .rotationEffect(.degrees(animateGold ? 360 : 0))
                            .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animateGold)

                        Image(systemName: "building.2.fill")
                            .font(.system(size: 48, weight: .light))
                            .foregroundStyle(.brandGold)
                    }

                    VStack(spacing: 8) {
                        Text("PROPHUB")
                            .font(.system(size: 36, weight: .light))
                            .tracking(12)
                            .foregroundStyle(.white)

                        Rectangle()
                            .fill(Color.goldGradient)
                            .frame(width: 60, height: 1.5)

                        Text("LUXURY LIVING EXPERIENCE")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(4)
                            .foregroundStyle(.brandGold.opacity(0.7))
                    }
                }

                Spacer()

                VStack(spacing: 24) {
                    Button {
                        Task { await authManager.signInWithDemoMode() }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.body)
                            Text("Enter Experience")
                                .font(.system(size: 16, weight: .semibold))
                                .tracking(1)
                        }
                        .foregroundStyle(.brandNavy)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.goldGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(authManager.isLoading)
                    .padding(.horizontal, 40)
                    .accessibilityLabel("Enter Demo Experience")

                    if authManager.isLoading {
                        ProgressView()
                            .tint(.brandGold)
                    }

                    Text("Exclusive demo for presales consultants")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(0.5)
                }

                Spacer().frame(height: 80)
            }
        }
        .onAppear { animateGold = true }
    }
}
