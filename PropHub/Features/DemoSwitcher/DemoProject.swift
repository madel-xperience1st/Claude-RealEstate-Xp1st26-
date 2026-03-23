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
    let developerIcon: String?
    let heroImageName: String?

    enum CodingKeys: String, CodingKey {
        case id, name, developer, logoUrl
        case brandPrimaryColor, brandSecondaryColor
        case description, status, defaultCurrency, unitCount
        case developerIcon, heroImageName
    }

    init(id: String, name: String, developer: String, logoUrl: String,
         brandPrimaryColor: String, brandSecondaryColor: String,
         description: String?, status: String, defaultCurrency: String,
         unitCount: Int?, developerIcon: String? = nil, heroImageName: String? = nil) {
        self.id = id
        self.name = name
        self.developer = developer
        self.logoUrl = logoUrl
        self.brandPrimaryColor = brandPrimaryColor
        self.brandSecondaryColor = brandSecondaryColor
        self.description = description
        self.status = status
        self.defaultCurrency = defaultCurrency
        self.unitCount = unitCount
        self.developerIcon = developerIcon
        self.heroImageName = heroImageName
    }
}
