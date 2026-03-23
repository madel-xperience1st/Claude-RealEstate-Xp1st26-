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
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                brandIcon
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(themeManager.developerName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.brandCharcoal)
                    .lineLimit(1)
                if let projectName = themeManager.activeProject?.name {
                    Text(projectName)
                        .font(.caption2)
                        .foregroundStyle(.brandGold)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(action: onSwitchDemo) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.subheadline)
                    .foregroundStyle(.brandNavy)
                    .padding(6)
                    .background(Circle().fill(Color.brandPlatinum))
            }
        }
    }

    private var brandIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.brandNavy)
                .frame(width: 30, height: 30)
            Image(systemName: "building.2.fill")
                .font(.caption)
                .foregroundStyle(.brandGold)
        }
    }
}
