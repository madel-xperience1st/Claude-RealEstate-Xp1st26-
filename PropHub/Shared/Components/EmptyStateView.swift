import SwiftUI

/// Elegant empty state with premium styling.
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.brandPlatinum)
                    .frame(width: 90, height: 90)
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(.brandGold)
            }

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.brandCharcoal)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.brandGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.brandNavy, in: Capsule())
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
