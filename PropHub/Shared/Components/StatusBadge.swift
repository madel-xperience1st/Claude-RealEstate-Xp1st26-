import SwiftUI

/// Elegant status badge with premium styling.
struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.10), in: Capsule())
            .accessibilityLabel(text)
    }

    static func forInstallmentStatus(_ status: String) -> StatusBadge {
        switch status.lowercased() {
        case "paid": return StatusBadge(text: status, color: .brandEmerald)
        case "upcoming": return StatusBadge(text: status, color: .brandSky)
        case "overdue": return StatusBadge(text: status, color: .brandCoral)
        case "pending": return StatusBadge(text: status, color: .brandGold)
        default: return StatusBadge(text: status, color: .brandGray)
        }
    }

    static func forUnitStatus(_ status: String) -> StatusBadge {
        switch status.lowercased() {
        case "delivered": return StatusBadge(text: status, color: .brandEmerald)
        case "handover ready": return StatusBadge(text: status, color: .brandSky)
        case "under construction": return StatusBadge(text: status, color: .brandGold)
        case "available": return StatusBadge(text: status, color: .statusAvailable)
        case "reserved": return StatusBadge(text: status, color: .statusReserved)
        case "sold": return StatusBadge(text: status, color: .brandGray)
        default: return StatusBadge(text: status, color: .brandGray)
        }
    }

    static func forServiceStatus(_ status: String) -> StatusBadge {
        switch status.lowercased() {
        case "new": return StatusBadge(text: status, color: .brandSky)
        case "assigned": return StatusBadge(text: status, color: .statusReserved)
        case "in progress": return StatusBadge(text: status, color: .brandGold)
        case "completed": return StatusBadge(text: status, color: .brandEmerald)
        default: return StatusBadge(text: status, color: .brandGray)
        }
    }
}
