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
    private let settings = AppSettings.shared

    /// Loads all dashboard data concurrently.
    func loadDashboard() async {
        isLoading = true
        error = nil

        if settings.useMockData {
            try? await Task.sleep(nanoseconds: 400_000_000)
            units = MockDataProvider.units
            totalUnits = units.count
            paymentSummary = MockDataProvider.paymentSummary
            recentServiceRequests = MockDataProvider.serviceRequests
            overdueCount = paymentSummary?.overdueCount ?? 0
            nextPaymentDate = paymentSummary?.nextDueDate
            openServiceRequests = recentServiceRequests.filter { $0.status != "Completed" }.count
            isLoading = false
            return
        }

        guard let projectId = userSession.activeProjectId,
              let contactId = userSession.contactId else {
            isLoading = false
            return
        }

        do {
            async let fetchedUnits: [Unit] = apiService.request(
                .listUnits(projectId: projectId, contactId: contactId, status: nil),
                cacheKey: "dashboard.units.\(projectId)"
            )

            units = try await fetchedUnits
            totalUnits = units.count

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
