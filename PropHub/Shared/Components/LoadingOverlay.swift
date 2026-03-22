import SwiftUI

/// Full-screen loading overlay with a blurred background and progress indicator.
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .accessibilityLabel(NSLocalizedString("loading", comment: ""))
    }
}
