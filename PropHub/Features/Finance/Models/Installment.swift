import Foundation

/// Model representing a payment installment from Salesforce `Installment__c`.
struct Installment: Codable, Identifiable, Equatable {
    let id: String
    let milestoneName: String
    let dueDate: Date
    let amount: Double
    let status: String
    let paidDate: Date?
    let penaltyAmount: Double?
    let sortOrder: Int?
}
