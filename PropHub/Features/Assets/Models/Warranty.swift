import Foundation

/// Warranty details for an asset.
struct Warranty: Codable, Equatable {
    let startDate: Date
    let endDate: Date
    let status: String
    let provider: String?
    let terms: String?
}
