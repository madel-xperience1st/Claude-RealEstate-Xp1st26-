import SwiftUI

/// Timeline view of all installments for a selected unit.
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
        VStack(spacing: 0) {
            // Payment Summary Card
            if let summary = viewModel.paymentSummary {
                paymentSummaryCard(summary)
            }

            // Tab Selector
            Picker("", selection: $selectedTab) {
                Text(NSLocalizedString("installments_tab", comment: "")).tag(0)
                Text(NSLocalizedString("invoices_tab", comment: "")).tag(1)
                Text(NSLocalizedString("overdue_tab", comment: "")).tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            // Tab Content
            switch selectedTab {
            case 0:
                installmentsList
            case 1:
                invoicesList
            case 2:
                overdueList
            default:
                installmentsList
            }
        }
        .navigationTitle(NSLocalizedString("finance_title", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .loading(viewModel.isLoading)
        .errorAlert(error: $viewModel.error) {
            Task { await viewModel.loadFinanceData() }
        }
        .task {
            await viewModel.loadFinanceData()
        }
    }

    // MARK: - Summary Card

    private func paymentSummaryCard(_ summary: PaymentSummary) -> some View {
        VStack(spacing: 12) {
            HStack {
                summaryItem(
                    label: NSLocalizedString("total_price_label", comment: ""),
                    amount: summary.totalPrice
                )
                Spacer()
                summaryItem(
                    label: NSLocalizedString("paid_amount_label", comment: ""),
                    amount: summary.paidAmount,
                    color: .green
                )
            }
            HStack {
                summaryItem(
                    label: NSLocalizedString("remaining_label", comment: ""),
                    amount: summary.remainingBalance,
                    color: .orange
                )
                Spacer()
                if let nextDue = summary.nextDueDate {
                    VStack(alignment: .trailing) {
                        Text(NSLocalizedString("next_due_label", comment: ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(nextDue.mediumFormatted)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.primaryColor.opacity(0.1))
        .accessibilityElement(children: .contain)
    }

    private func summaryItem(label: String, amount: Double, color: Color = .primary) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            CurrencyText(amount: amount, currencyCode: themeManager.currencyCode, style: .body)
                .foregroundStyle(color)
        }
    }

    // MARK: - Lists

    private var installmentsList: some View {
        List {
            ForEach(viewModel.installments) { installment in
                InstallmentRow(installment: installment)
            }
        }
        .listStyle(.plain)
        .emptyState(
            viewModel.installments.isEmpty && !viewModel.isLoading,
            icon: "creditcard",
            title: NSLocalizedString("no_installments_title", comment: ""),
            message: NSLocalizedString("no_installments_message", comment: "")
        )
    }

    private var invoicesList: some View {
        InvoiceListView(viewModel: viewModel)
    }

    private var overdueList: some View {
        OverdueView(viewModel: viewModel)
    }
}

/// Row displaying a single installment milestone.
struct InstallmentRow: View {
    let installment: Installment

    var body: some View {
        HStack {
            // Timeline dot
            Circle()
                .fill(colorForStatus(installment.status))
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(installment.milestoneName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(installment.dueDate.mediumFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                CurrencyText(amount: installment.amount, style: .body)
                StatusBadge.forInstallmentStatus(installment.status)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private func colorForStatus(_ status: String) -> Color {
        switch status.lowercased() {
        case "paid": return .green
        case "overdue": return .red
        case "upcoming": return .blue
        default: return .gray
        }
    }
}
