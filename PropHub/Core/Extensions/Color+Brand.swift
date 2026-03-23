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

    // MARK: - Premium Brand Colors (Asset Catalog with fallback)

    /// Deep navy — primary brand color
    static let brandNavy = Color("Colors/BrandNavy", bundle: .main)
    /// Rich gold — accent color
    static let brandGold = Color("Colors/BrandGold", bundle: .main)
    /// Light champagne gold — subtle highlights
    static let brandChampagne = Color("Colors/BrandChampagne", bundle: .main)
    /// Warm white — background
    static let brandWhite = Color("Colors/BrandWhite", bundle: .main)
    /// Soft platinum — card backgrounds
    static let brandPlatinum = Color("Colors/BrandPlatinum", bundle: .main)
    /// Emerald green — success states
    static let brandEmerald = Color("Colors/BrandEmerald", bundle: .main)
    /// Coral red — error/overdue states
    static let brandCoral = Color("Colors/BrandCoral", bundle: .main)
    /// Sky blue — info/upcoming states
    static let brandSky = Color("Colors/BrandSky", bundle: .main)
    /// Warm gray — secondary text
    static let brandGray = Color("Colors/BrandGray", bundle: .main)
    /// Deep charcoal — primary text
    static let brandCharcoal = Color("Colors/BrandCharcoal", bundle: .main)

    // MARK: - Status Colors (Asset Catalog)

    /// Teal — available status
    static let statusAvailable = Color("Colors/StatusAvailable", bundle: .main)
    /// Purple — reserved/assigned status
    static let statusReserved = Color("Colors/StatusReserved", bundle: .main)

    // MARK: - Gradients

    /// Premium gradient from navy to deep navy
    static var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [.brandNavy, Color("Colors/GradientNavyEnd", bundle: .main)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    /// Gold shimmer gradient
    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("Colors/GradientGoldStart", bundle: .main),
                .brandGold,
                Color("Colors/GradientGoldEnd", bundle: .main)
            ],
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

// MARK: - ShapeStyle convenience so .brandGold works in foregroundStyle/tint

extension ShapeStyle where Self == Color {
    static var brandNavy: Color { Color.brandNavy }
    static var brandGold: Color { Color.brandGold }
    static var brandChampagne: Color { Color.brandChampagne }
    static var brandWhite: Color { Color.brandWhite }
    static var brandPlatinum: Color { Color.brandPlatinum }
    static var brandEmerald: Color { Color.brandEmerald }
    static var brandCoral: Color { Color.brandCoral }
    static var brandSky: Color { Color.brandSky }
    static var brandGray: Color { Color.brandGray }
    static var brandCharcoal: Color { Color.brandCharcoal }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
