import SwiftUI

/// Generates a beautiful gradient hero image for projects and units
/// when no real image is available. Uses the developer's brand colors.
struct ProjectHeroImage: View {
    let primaryColor: Color
    let secondaryColor: Color
    let icon: String
    let title: String?
    var height: CGFloat = 200

    var body: some View {
        ZStack {
            // Multi-layer gradient background
            LinearGradient(
                colors: [
                    primaryColor,
                    primaryColor.opacity(0.85),
                    primaryColor.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(secondaryColor.opacity(0.08))
                    .frame(width: geo.size.width * 0.7)
                    .offset(x: geo.size.width * 0.5, y: -geo.size.height * 0.2)

                Circle()
                    .fill(secondaryColor.opacity(0.05))
                    .frame(width: geo.size.width * 0.5)
                    .offset(x: -geo.size.width * 0.15, y: geo.size.height * 0.5)

                // Diagonal accent line
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [secondaryColor.opacity(0.2), secondaryColor.opacity(0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * 1.5, height: 1)
                    .rotationEffect(.degrees(-25))
                    .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.35)
            }

            // Icon and title overlay
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .light))
                    .foregroundStyle(secondaryColor.opacity(0.5))

                if let title = title {
                    Text(title)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .frame(height: height)
        .clipped()
    }
}

/// Generates a unit-specific hero card with floor/type info.
struct UnitHeroCard: View {
    let unit: Unit
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ProjectHeroImage(
                primaryColor: themeManager.primaryColor,
                secondaryColor: themeManager.secondaryColor,
                icon: unitIcon,
                title: nil,
                height: 160
            )

            // Unit info overlay
            VStack(alignment: .leading, spacing: 4) {
                Text(unit.unitType.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(themeManager.secondaryColor)

                Text(unit.unitNumber)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(unit.building)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var unitIcon: String {
        switch unit.unitType.lowercased() {
        case "villa": return "house.fill"
        case "penthouse": return "crown.fill"
        case "1br": return "bed.double.fill"
        case "2br": return "bed.double.fill"
        case "3br": return "bed.double.fill"
        default: return "building.fill"
        }
    }
}
