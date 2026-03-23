import Foundation

/// Model representing a service request (Salesforce Case).
struct ServiceRequest: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let caseNumber: String
    let category: String
    let subject: String
    let status: String
    let createdDate: Date
    let assignedTechnician: String?
    let description: String?
    let preferredDate: Date?
    let relatedAssetId: String?
}
