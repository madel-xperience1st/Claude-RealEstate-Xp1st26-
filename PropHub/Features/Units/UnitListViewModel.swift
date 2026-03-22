import Foundation

/// View model for the units list screen.
@MainActor
final class UnitListViewModel: ObservableObject {
    @Published var units: [Unit] = []
    @Published var isLoading = false
    @Published var error: APIError?

    private let apiService = APIService.shared
    private let userSession = UserSession.shared

    /// Fetches all units for the active demo project and contact.
    func loadUnits() async {
        guard let projectId = userSession.activeProjectId,
              let contactId = userSession.contactId else { return }

        isLoading = true
        error = nil

        do {
            units = try await apiService.request(
                .listUnits(projectId: projectId, contactId: contactId, status: nil),
                cacheKey: "units.list.\(projectId).\(contactId)"
            )
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }
}
