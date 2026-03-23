import Foundation

/// Model representing a registered asset in a delivered unit (Salesforce `Asset`).
struct Asset: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let serialNumber: String?
    let manufacturer: String?
    let installDate: Date?
    let warrantyEndDate: Date?
    let warrantyStatus: String
    let category: String
}
