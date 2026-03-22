import SwiftUI

/// Colored badge displaying a status label (e.g., "Paid", "Overdue", "In Progress").
struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color, in: Capsule())
            .accessibilityLabel(text)
    }

    /// Creates a status badge for common installment statuses.
    static func forInstallmentStatus(_ status: String) -> StatusBadge {
        switch status.lowercased() {
        case "paid":
            return StatusBadge(text: status, color: .green)
        case "upcoming":
            return StatusBadge(text: status, color: .blue)
        case "overdue":
            return StatusBadge(text: status, color: .red)
        case "pending":
            return StatusBadge(text: status, color: .orange)
        default:
            return StatusBadge(text: status, color: .gray)
        }
    }

    /// Creates a status badge for unit statuses.
    static func forUnitStatus(_ status: String) -> StatusBadge {
        switch status.lowercased() {
        case "delivered":
            return StatusBadge(text: status, color: .green)
        case "handover ready":
            return StatusBadge(text: status, color: .blue)
        case "under construction":
            return StatusBadge(text: status, color: .orange)
        case "available":
            return StatusBadge(text: status, color: .teal)
        case "reserved":
            return StatusBadge(text: status, color: .purple)
        case "sold":
            return StatusBadge(text: status, color: .gray)
        default:
            return StatusBadge(text: status, color: .gray)
        }
    }

    /// Creates a status badge for service request statuses.
    static func forServiceStatus(_ status: String) -> StatusBadge {
        switch status.lowercased() {
        case "new":
            return StatusBadge(text: status, color: .blue)
        case "assigned":
            return StatusBadge(text: status, color: .purple)
        case "in progress":
            return StatusBadge(text: status, color: .orange)
        case "completed":
            return StatusBadge(text: status, color: .green)
        default:
            return StatusBadge(text: status, color: .gray)
        }
    }
}
