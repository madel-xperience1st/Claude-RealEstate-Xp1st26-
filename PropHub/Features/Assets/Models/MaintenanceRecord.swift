import Foundation

/// Model representing a maintenance work order from Salesforce `WorkOrder`.
struct MaintenanceRecord: Codable, Identifiable, Equatable {
    let id: String
    let workOrderNumber: String
    let scheduledDate: Date
    let status: String
    let technicianName: String?
    let type: String?
}
