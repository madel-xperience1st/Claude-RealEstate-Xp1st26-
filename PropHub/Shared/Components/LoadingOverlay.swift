import SwiftUI

/// Premium loading overlay with gold accent.
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(.brandGold)
                Text("Loading")
                    .font(.caption)
                    .foregroundStyle(.brandGray)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}
