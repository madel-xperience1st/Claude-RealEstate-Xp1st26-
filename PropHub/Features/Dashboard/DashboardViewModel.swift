import Foundation

/// View model for the main dashboard, aggregating data from multiple API endpoints.
@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var units: [Unit] = []
    @Published var paymentSummary: PaymentSummary?
    @Published var recentServiceRequests: [ServiceRequest] = []
    @Published var totalUnits = 0
    @Published var openServiceRequests = 0
    @Published var overdueCount = 0
    @Published var nextPaymentDate: Date?
    @Published var isLoading = false
    @Published var error: APIError?

    private let apiService = APIService.shared
    private let userSession = UserSession.shared

    /// Loads all dashboard data concurrently.
    func loadDashboard() async {
        guard let projectId = userSession.activeProjectId,
              let contactId = userSession.contactId else { return }

        isLoading = true
        error = nil

        do {
            // Fetch units and service requests concurrently
            async let fetchedUnits: [Unit] = apiService.request(
                .listUnits(projectId: projectId, contactId: contactId, status: nil),
                cacheKey: "dashboard.units.\(projectId)"
            )

            units = try await fetchedUnits
            totalUnits = units.count

            // Fetch payment summary for the first unit if available
            if let firstUnit = units.first {
                async let summary: PaymentSummary = apiService.request(
                    .paymentSummary(unitId: firstUnit.id),
                    cacheKey: "dashboard.payment.\(firstUnit.id)"
                )
                async let requests: [ServiceRequest] = apiService.request(
                    .listServiceRequests(unitId: firstUnit.id, status: nil),
                    cacheKey: "dashboard.services.\(firstUnit.id)"
                )

                paymentSummary = try await summary
                recentServiceRequests = try await requests
                overdueCount = paymentSummary?.overdueCount ?? 0
                nextPaymentDate = paymentSummary?.nextDueDate
                openServiceRequests = recentServiceRequests.filter {
                    $0.status != "Completed"
                }.count
            }
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }
}
