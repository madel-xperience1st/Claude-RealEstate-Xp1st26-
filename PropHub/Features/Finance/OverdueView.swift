import SwiftUI

/// Premium overdue payments view with urgency styling.
struct OverdueView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            ForEach(viewModel.overdueInstallments) { installment in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(installment.milestoneName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.brandCharcoal)
                        Spacer()
                        CurrencyText(
                            amount: installment.amount,
                            currencyCode: themeManager.currencyCode,
                            style: .body
                        )
                        .foregroundStyle(.brandCoral)
                    }

                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.brandCoral)
                            Text("\(abs(installment.dueDate.daysFromToday)) days overdue")
                                .font(.caption)
                                .foregroundStyle(.brandCoral)
                        }

                        if let penalty = installment.penaltyAmount, penalty > 0 {
                            Spacer()
                            HStack(spacing: 4) {
                                Text("Penalty:")
                                    .font(.caption)
                                    .foregroundStyle(.brandGray)
                                CurrencyText(
                                    amount: penalty,
                                    currencyCode: themeManager.currencyCode,
                                    style: .caption
                                )
                                .foregroundStyle(.brandCoral)
                            }
                        }
                    }

                    Button {} label: {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                            Text("Contact Support")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.brandNavy)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.brandChampagne, in: Capsule())
                    }
                }
                .padding(.vertical, 6)
                .listRowBackground(Color.brandWhite)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .emptyState(
            viewModel.overdueInstallments.isEmpty && !viewModel.isLoading,
            icon: "checkmark.circle",
            title: "All Clear",
            message: "No overdue payments. You're up to date!"
        )
    }
}
