import Foundation

/// Aggregated payment summary for a unit.
struct PaymentSummary: Codable, Equatable {
    let totalPrice: Double
    let paidAmount: Double
    let remainingBalance: Double
    let nextDueDate: Date?
    let overdueCount: Int
    let overdueAmount: Double
}
