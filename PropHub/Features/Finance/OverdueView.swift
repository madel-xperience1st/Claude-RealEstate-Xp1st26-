import SwiftUI

/// Filtered view showing only overdue installments with penalty and contact action.
struct OverdueView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            ForEach(viewModel.overdueInstallments) { installment in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(installment.milestoneName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        CurrencyText(
                            amount: installment.amount,
                            currencyCode: themeManager.currencyCode,
                            style: .body
                        )
                    }

                    HStack {
                        Text(
                            String(
                                format: NSLocalizedString("days_overdue", comment: ""),
                                abs(installment.dueDate.daysFromToday)
                            )
                        )
                        .font(.caption)
                        .foregroundStyle(.red)

                        if let penalty = installment.penaltyAmount, penalty > 0 {
                            Spacer()
                            HStack(spacing: 4) {
                                Text(NSLocalizedString("penalty_label", comment: ""))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                CurrencyText(
                                    amount: penalty,
                                    currencyCode: themeManager.currencyCode,
                                    style: .caption
                                )
                                .foregroundStyle(.red)
                            }
                        }
                    }

                    Button {
                        // Contact action — deep-link to chat or support
                    } label: {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text(NSLocalizedString("contact_us", comment: ""))
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .accessibilityLabel(NSLocalizedString("contact_us", comment: ""))
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
        .emptyState(
            viewModel.overdueInstallments.isEmpty && !viewModel.isLoading,
            icon: "checkmark.circle",
            title: NSLocalizedString("no_overdue_title", comment: ""),
            message: NSLocalizedString("no_overdue_message", comment: "")
        )
    }
}
