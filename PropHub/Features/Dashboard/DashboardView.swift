import SwiftUI

/// Main dashboard showing an overview of the user's units, payments, and recent activity.
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showDemoSwitcher = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Stats
                    quickStatsSection

                    // My Units Preview
                    unitsSummarySection

                    // Payment Overview
                    paymentOverviewSection

                    // Recent Activity
                    recentActivitySection
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("tab_dashboard", comment: ""))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BrandedNavigationBar(onSwitchDemo: {
                        showDemoSwitcher = true
                    })
                    .frame(width: 200)
                }
            }
            .sheet(isPresented: $showDemoSwitcher) {
                DemoSwitcherView()
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error) {
                Task { await viewModel.loadDashboard() }
            }
            .task {
                await viewModel.loadDashboard()
            }
        }
    }

    // MARK: - Sections

    private var quickStatsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: NSLocalizedString("total_units", comment: ""),
                value: "\(viewModel.totalUnits)",
                icon: "building.2",
                color: themeManager.primaryColor
            )
            StatCard(
                title: NSLocalizedString("open_requests", comment: ""),
                value: "\(viewModel.openServiceRequests)",
                icon: "wrench.and.screwdriver",
                color: .orange
            )
            StatCard(
                title: NSLocalizedString("overdue_payments", comment: ""),
                value: "\(viewModel.overdueCount)",
                icon: "exclamationmark.circle",
                color: viewModel.overdueCount > 0 ? .red : .green
            )
            StatCard(
                title: NSLocalizedString("next_payment", comment: ""),
                value: viewModel.nextPaymentDate?.mediumFormatted ?? "-",
                icon: "calendar",
                color: .blue
            )
        }
    }

    private var unitsSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("my_units", comment: ""))
                .font(.headline)

            if viewModel.units.isEmpty {
                Text(NSLocalizedString("no_units", comment: ""))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.units.prefix(3), id: \.id) { unit in
                    UnitSummaryRow(unit: unit)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var paymentOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("payment_overview", comment: ""))
                .font(.headline)

            if let summary = viewModel.paymentSummary {
                VStack(spacing: 8) {
                    HStack {
                        Text(NSLocalizedString("total_price_label", comment: ""))
                        Spacer()
                        CurrencyText(
                            amount: summary.totalPrice,
                            currencyCode: themeManager.currencyCode,
                            style: .body
                        )
                    }
                    HStack {
                        Text(NSLocalizedString("paid_amount_label", comment: ""))
                        Spacer()
                        CurrencyText(
                            amount: summary.paidAmount,
                            currencyCode: themeManager.currencyCode,
                            style: .body
                        )
                        .foregroundStyle(.green)
                    }
                    HStack {
                        Text(NSLocalizedString("remaining_label", comment: ""))
                        Spacer()
                        CurrencyText(
                            amount: summary.remainingBalance,
                            currencyCode: themeManager.currencyCode,
                            style: .body
                        )
                        .foregroundStyle(.orange)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(.background))
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("recent_activity", comment: ""))
                .font(.headline)

            if viewModel.recentServiceRequests.isEmpty {
                Text(NSLocalizedString("no_recent_activity", comment: ""))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.recentServiceRequests.prefix(3), id: \.id) { request in
                    ServiceRequestRow(request: request)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Quick stat card for the dashboard grid.
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .accessibilityHidden(true)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.background))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .accessibilityElement(children: .combine)
    }
}

/// Compact unit row for the dashboard.
struct UnitSummaryRow: View {
    let unit: Unit

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(unit.unitNumber)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(unit.building)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadge.forUnitStatus(unit.status)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

/// Compact service request row for the dashboard.
struct ServiceRequestRow: View {
    let request: ServiceRequest

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(request.subject)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(request.caseNumber)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadge.forServiceStatus(request.status)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
