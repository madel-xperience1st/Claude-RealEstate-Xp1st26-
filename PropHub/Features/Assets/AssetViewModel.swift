import Foundation

/// View model managing asset listing, warranty details, and maintenance schedules.
@MainActor
final class AssetViewModel: ObservableObject {
    @Published var assets: [Asset] = []
    @Published var warranty: Warranty?
    @Published var maintenanceRecords: [MaintenanceRecord] = []
    @Published var isLoading = false
    @Published var error: APIError?

    private let apiService = APIService.shared

    /// Fetches all assets for a unit.
    func loadAssets(unitId: String) async {
        isLoading = true
        error = nil

        do {
            assets = try await apiService.request(
                .listAssets(unitId: unitId),
                cacheKey: "assets.\(unitId)"
            )
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    /// Fetches warranty details for a specific asset.
    func loadWarranty(assetId: String) async {
        do {
            warranty = try await apiService.request(
                .assetWarranty(assetId: assetId),
                cacheKey: "warranty.\(assetId)"
            )
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }
    }

    /// Fetches maintenance records for a specific asset.
    func loadMaintenance(assetId: String) async {
        do {
            maintenanceRecords = try await apiService.request(
                .assetMaintenance(assetId: assetId),
                cacheKey: "maintenance.\(assetId)"
            )
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }
    }
}
