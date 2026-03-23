import SwiftUI
import Kingfisher

/// Premium navigation bar with developer branding.
struct BrandedNavigationBar: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onSwitchDemo: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            if let logoURL = themeManager.logoURL {
                KFImage(logoURL)
                    .placeholder { brandIcon }
                    .onFailure { _ in }
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemBackground))
                    )
            } else {
                brandIcon
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(themeManager.developerName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.brandCharcoal)
                    .lineLimit(1)
                if let projectName = themeManager.activeProject?.name {
                    Text(projectName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(themeManager.secondaryColor)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(action: onSwitchDemo) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(themeManager.primaryColor)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(themeManager.primaryColor.opacity(0.08))
                    )
            }
        }
    }

    private var brandIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [themeManager.primaryColor, themeManager.primaryColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
            Image(systemName: themeManager.developerIcon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(themeManager.secondaryColor)
        }
    }
}
