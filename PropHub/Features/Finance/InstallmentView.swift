import SwiftUI

/// Premium finance view with payment timeline.
struct InstallmentView: View {
    let unitId: String
    @StateObject private var viewModel: FinanceViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0

    init(unitId: String) {
        self.unitId = unitId
        _viewModel = StateObject(wrappedValue: FinanceViewModel(unitId: unitId))
    }

    var body: some View {
        ZStack {
            Color.brandWhite.ignoresSafeArea()

            VStack(spacing: 0) {
                // Payment Summary Card
                if let summary = viewModel.paymentSummary {
                    paymentSummaryCard(summary)
                }

                // Tab Selector
                Picker("", selection: $selectedTab) {
                    Text("Installments").tag(0)
                    Text("Invoices").tag(1)
                    Text("Overdue").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                switch selectedTab {
                case 0: installmentsList
                case 1: invoicesList
                case 2: overdueList
                default: installmentsList
                }
            }
        }
        .navigationTitle("Finance")
        .navigationBarTitleDisplayMode(.inline)
        .loading(viewModel.isLoading)
        .errorAlert(error: $viewModel.error) {
            Task { await viewModel.loadFinanceData() }
        }
        .task {
            await viewModel.loadFinanceData()
        }
    }

    private func paymentSummaryCard(_ summary: PaymentSummary) -> some View {
        VStack(spacing: 16) {
            HStack {
                summaryItem(label: "Total", amount: summary.totalPrice, color: .white)
                Spacer()
                summaryItem(label: "Paid", amount: summary.paidAmount, color: .brandChampagne)
            }
            HStack {
                summaryItem(label: "Remaining", amount: summary.remainingBalance, color: .brandGold)
                Spacer()
                if let nextDue = summary.nextDueDate {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("NEXT DUE")
                            .font(.system(size: 9, weight: .medium))
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.6))
                        Text(nextDue.mediumFormatted)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [themeManager.primaryColor, themeManager.primaryColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func summaryItem(label: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.6))
            CurrencyText(amount: amount, currencyCode: themeManager.currencyCode, style: .body)
                .foregroundStyle(color)
        }
    }

    private var installmentsList: some View {
        List {
            ForEach(viewModel.installments) { installment in
                InstallmentRow(installment: installment)
                    .listRowBackground(Color(.systemBackground))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .emptyState(
            viewModel.installments.isEmpty && !viewModel.isLoading,
            icon: "creditcard",
            title: "No Installments",
            message: "No payment installments found."
        )
    }

    private var invoicesList: some View {
        InvoiceListView(viewModel: viewModel)
    }

    private var overdueList: some View {
        OverdueView(viewModel: viewModel)
    }
}

/// Premium installment row with timeline dot.
struct InstallmentRow: View {
    let installment: Installment

    var body: some View {
        HStack(spacing: 14) {
            // Timeline dot
            ZStack {
                Circle()
                    .fill(colorForStatus(installment.status).opacity(0.15))
                    .frame(width: 28, height: 28)
                Circle()
                    .fill(colorForStatus(installment.status))
                    .frame(width: 10, height: 10)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(installment.milestoneName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.brandCharcoal)
                Text(installment.dueDate.mediumFormatted)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.brandGray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                CurrencyText(amount: installment.amount, style: .body)
                    .foregroundStyle(.brandCharcoal)
                StatusBadge.forInstallmentStatus(installment.status)
            }
        }
        .padding(.vertical, 6)
    }

    private func colorForStatus(_ status: String) -> Color {
        switch status.lowercased() {
        case "paid": return .brandEmerald
        case "overdue": return .brandCoral
        case "upcoming": return .brandSky
        default: return .brandGray
        }
    }
}
