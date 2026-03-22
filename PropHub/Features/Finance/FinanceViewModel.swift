import Foundation

/// View model managing installments, invoices, and payment summaries for a unit.
@MainActor
final class FinanceViewModel: ObservableObject {
    @Published var installments: [Installment] = []
    @Published var invoices: [Invoice] = []
    @Published var paymentSummary: PaymentSummary?
    @Published var isLoading = false
    @Published var error: APIError?

    private let apiService = APIService.shared
    private let settings = AppSettings.shared
    private let unitId: String

    init(unitId: String) {
        self.unitId = unitId
    }

    /// Loads all finance data for the unit concurrently.
    func loadFinanceData() async {
        isLoading = true
        error = nil

        if settings.useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            installments = MockDataProvider.installments
            invoices = MockDataProvider.invoices
            paymentSummary = MockDataProvider.paymentSummary
            isLoading = false
            return
        }

        do {
            async let fetchedInstallments: [Installment] = apiService.request(
                .installments(unitId: unitId),
                cacheKey: "finance.installments.\(unitId)"
            )
            async let fetchedInvoices: [Invoice] = apiService.request(
                .invoices(unitId: unitId),
                cacheKey: "finance.invoices.\(unitId)"
            )
            async let fetchedSummary: PaymentSummary = apiService.request(
                .paymentSummary(unitId: unitId),
                cacheKey: "finance.summary.\(unitId)"
            )

            installments = try await fetchedInstallments
            invoices = try await fetchedInvoices
            paymentSummary = try await fetchedSummary
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    /// Filtered view of only overdue installments.
    var overdueInstallments: [Installment] {
        installments.filter { $0.status == "Overdue" }
    }

    /// Downloads an invoice PDF as raw data.
    func downloadInvoicePDF(invoiceId: String) async throws -> Data {
        try await apiService.requestData(.invoicePDF(unitId: unitId, invoiceId: invoiceId))
    }
}
