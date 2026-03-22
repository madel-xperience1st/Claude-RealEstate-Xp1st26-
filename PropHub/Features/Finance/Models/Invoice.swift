import Foundation

/// Model representing an invoice from Salesforce `Invoice__c`.
struct Invoice: Codable, Identifiable, Equatable {
    let id: String
    let invoiceNumber: String
    let date: Date
    let amount: Double
    let status: String
    let pdfUrl: String?
}
