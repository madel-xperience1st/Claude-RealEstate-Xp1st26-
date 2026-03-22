import SwiftUI
import Kingfisher

/// Custom navigation bar that displays the active demo project's branding.
/// Includes the developer logo, project name, and a demo switcher button.
struct BrandedNavigationBar: View {
    @EnvironmentObject var themeManager: ThemeManager
    let onSwitchDemo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Developer Logo
            if let logoURL = themeManager.logoURL {
                KFImage(logoURL)
                    .placeholder {
                        Image(systemName: "building.2.fill")
                            .foregroundStyle(themeManager.primaryColor)
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .accessibilityLabel(themeManager.developerName)
            } else {
                Image(systemName: "building.2.fill")
                    .font(.title2)
                    .foregroundStyle(themeManager.primaryColor)
                    .accessibilityHidden(true)
            }

            // Developer / Project Name
            VStack(alignment: .leading, spacing: 2) {
                Text(themeManager.developerName)
                    .font(.headline)
                    .lineLimit(1)
                if let projectName = themeManager.activeProject?.name {
                    Text(projectName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Demo Switcher Button
            Button(action: onSwitchDemo) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.title3)
                    .foregroundStyle(themeManager.primaryColor)
            }
            .accessibilityLabel(NSLocalizedString("switch_demo", comment: ""))
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}
