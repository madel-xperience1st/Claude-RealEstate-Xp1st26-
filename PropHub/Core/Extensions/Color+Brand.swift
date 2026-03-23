import SwiftUI

extension Color {
    /// Initializes a Color from a hex string (e.g., "#1B4D8E" or "1B4D8E").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red, green, blue, alpha: UInt64
        switch hex.count {
        case 3:
            (red, green, blue, alpha) = (
                (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255
            )
        case 6:
            (red, green, blue, alpha) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (red, green, blue, alpha) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, int >> 24)
        default:
            (red, green, blue, alpha) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255, green: Double(green) / 255,
            blue: Double(blue) / 255, opacity: Double(alpha) / 255
        )
    }

    var hexString: String {
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        let red = Int((components[safe: 0] ?? 0) * 255)
        let green = Int((components[safe: 1] ?? 0) * 255)
        let blue = Int((components[safe: 2] ?? 0) * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    // MARK: - Premium Brand Colors (Emaar-inspired)

    /// Deep navy — primary brand color
    static let brandNavy = Color(hex: "0A1628")
    /// Rich gold — accent color
    static let brandGold = Color(hex: "C8A951")
    /// Light champagne gold — subtle highlights
    static let brandChampagne = Color(hex: "F5ECD7")
    /// Warm white — background
    static let brandWhite = Color(hex: "FAFAF8")
    /// Soft platinum — card backgrounds
    static let brandPlatinum = Color(hex: "F2F2EF")
    /// Emerald green — success states
    static let brandEmerald = Color(hex: "2E8B57")
    /// Coral red — error/overdue states
    static let brandCoral = Color(hex: "E8584F")
    /// Sky blue — info/upcoming states
    static let brandSky = Color(hex: "4A90D9")
    /// Warm gray — secondary text
    static let brandGray = Color(hex: "8E8E93")
    /// Deep charcoal — primary text
    static let brandCharcoal = Color(hex: "1C1C1E")

    /// Premium gradient from navy to gold
    static var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [.brandNavy, Color(hex: "1A2A4A")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    /// Gold shimmer gradient
    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "D4AF37"), .brandGold, Color(hex: "E8D48B")],
            startPoint: .leading, endPoint: .trailing
        )
    }

    /// Light card gradient
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [.white, .brandPlatinum],
            startPoint: .top, endPoint: .bottom
        )
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
