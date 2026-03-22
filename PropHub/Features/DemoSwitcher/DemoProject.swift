import Foundation

/// Model representing a demo project fetched from Salesforce `Demo_Project__c`.
/// Each project defines branding, developer info, and available units.
struct DemoProject: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let developer: String
    let logoUrl: String
    let brandPrimaryColor: String
    let brandSecondaryColor: String
    let description: String?
    let status: String
    let defaultCurrency: String
    let unitCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case developer
        case logoUrl
        case brandPrimaryColor
        case brandSecondaryColor
        case description
        case status
        case defaultCurrency
        case unitCount
    }
}
