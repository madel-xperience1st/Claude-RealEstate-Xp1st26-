import Foundation

/// Model representing a real estate unit from Salesforce `Unit__c`.
struct Unit: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let unitNumber: String
    let building: String
    let floor: Int
    let areaSqm: Double
    let areaSqft: Double
    let unitType: String
    let status: String
    let handoverDate: Date?
    let totalPrice: Double
    let floorPlanUrl: String?
    let paymentCompletion: Double?
    let projectName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case unitNumber
        case building
        case floor
        case areaSqm
        case areaSqft
        case unitType
        case status
        case handoverDate
        case totalPrice
        case floorPlanUrl
        case paymentCompletion
        case projectName
    }
}
