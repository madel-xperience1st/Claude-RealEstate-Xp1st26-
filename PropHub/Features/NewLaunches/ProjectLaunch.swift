import Foundation

/// Model representing a new project launch from Salesforce `Project_Launch__c`.
struct ProjectLaunch: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String?
    let priceRangeMin: Double?
    let priceRangeMax: Double?
    let expectedHandover: String?
    let heroImageUrls: String?
    let amenities: String?
    let launchDate: Date?
    let isActive: Bool

    /// Parsed hero image URLs from the comma-separated string.
    var imageURLs: [URL] {
        guard let urls = heroImageUrls else { return [] }
        return urls.split(separator: ",")
            .compactMap { URL(string: String($0).trimmingCharacters(in: .whitespaces)) }
    }

    /// Parsed amenities list from the JSON array string.
    var amenitiesList: [String] {
        guard let json = amenities?.data(using: .utf8),
              let list = try? JSONDecoder().decode([String].self, from: json) else {
            return []
        }
        return list
    }
}

/// Model representing a waitlist entry from Salesforce `Waitlist_Entry__c`.
struct WaitlistEntry: Codable, Identifiable {
    let id: String
    let status: String
    let registrationDate: Date?
    let preferredUnitType: String?
}
