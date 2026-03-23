import SwiftUI

/// Premium dashboard — Emaar-inspired with hero welcome, stat cards, and elegant sections.
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showDemoSwitcher = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Hero Welcome Card
                    heroWelcomeCard

                    // Quick Stats
                    quickStatsSection

                    // My Units
                    unitsSummarySection

                    // Payment Overview
                    paymentOverviewSection

                    // Recent Activity
                    recentActivitySection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color.brandWhite.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    BrandedNavigationBar(onSwitchDemo: { showDemoSwitcher = true })
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

    // MARK: - Hero Welcome Card

    private var heroWelcomeCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.premiumGradient)
                .frame(height: 160)

            // Gold accent line
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.brandGold.opacity(0.08))
                        .frame(width: 200, height: 200)
                        .offset(x: 50, y: 60)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome back")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))

                Text(themeManager.developerName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.brandGold)
                        .frame(width: 6, height: 6)
                    Text(themeManager.activeProject?.name ?? "Select a project")
                        .font(.caption)
                        .foregroundStyle(.brandGold)
                }
            }
            .padding(24)
        }
        .padding(.top, 8)
    }

    // MARK: - Quick Stats

    private var quickStatsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            StatCard(
                title: "Total Units",
                value: "\(viewModel.totalUnits)",
                icon: "building.2",
                color: themeManager.primaryColor
            )
            StatCard(
                title: "Open Requests",
                value: "\(viewModel.openServiceRequests)",
                icon: "wrench.and.screwdriver",
                color: .brandGold
            )
            StatCard(
                title: "Overdue",
                value: "\(viewModel.overdueCount)",
                icon: "exclamationmark.circle",
                color: viewModel.overdueCount > 0 ? .brandCoral : .brandEmerald
            )
            StatCard(
                title: "Next Payment",
                value: viewModel.nextPaymentDate?.mediumFormatted ?? "-",
                icon: "calendar",
                color: .brandSky
            )
        }
    }

    // MARK: - Units Summary

    private var unitsSummarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "My Units", icon: "building.2.fill")

            if viewModel.units.isEmpty {
                Text("No units available")
                    .font(.subheadline)
                    .foregroundStyle(.brandGray)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.units.prefix(3).enumerated()), id: \.element.id) { index, unit in
                        UnitSummaryRow(unit: unit)
                        if index < min(viewModel.units.count, 3) - 1 {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                )
            }
        }
    }

    // MARK: - Payment Overview

    private var paymentOverviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Payment Overview", icon: "creditcard.fill")

            if let summary = viewModel.paymentSummary {
                VStack(spacing: 12) {
                    PaymentRow(
                        label: "Total Price",
                        amount: summary.totalPrice,
                        currencyCode: themeManager.currencyCode,
                        color: .brandCharcoal
                    )
                    Divider()
                    PaymentRow(
                        label: "Paid",
                        amount: summary.paidAmount,
                        currencyCode: themeManager.currencyCode,
                        color: .brandEmerald
                    )
                    Divider()
                    PaymentRow(
                        label: "Remaining",
                        amount: summary.remainingBalance,
                        currencyCode: themeManager.currencyCode,
                        color: .brandGold
                    )
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                )
            }
        }
    }

    // MARK: - Recent Activity

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Recent Activity", icon: "clock.fill")

            if viewModel.recentServiceRequests.isEmpty {
                Text("No recent activity")
                    .font(.subheadline)
                    .foregroundStyle(.brandGray)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.recentServiceRequests.prefix(3).enumerated()), id: \.element.id) { index, request in
                        ServiceRequestRow(request: request)
                        if index < min(viewModel.recentServiceRequests.count, 3) - 1 {
                            Divider().padding(.leading, 16)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                )
            }
        }
    }
}

// MARK: - Supporting Components

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.brandGold)
            Text(title)
                .font(.headline)
                .foregroundStyle(.brandCharcoal)
        }
    }
}

struct PaymentRow: View {
    let label: String
    let amount: Double
    let currencyCode: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.brandGray)
            Spacer()
            CurrencyText(amount: amount, currencyCode: currencyCode, style: .body)
                .foregroundStyle(color)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.brandCharcoal)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(title)
                .font(.caption)
                .foregroundStyle(.brandGray)
                .lineLimit(1)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
        )
        .accessibilityElement(children: .combine)
    }
}

struct UnitSummaryRow: View {
    let unit: Unit

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(unit.unitNumber)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.brandCharcoal)
                Text(unit.building)
                    .font(.caption)
                    .foregroundStyle(.brandGray)
            }
            Spacer()
            StatusBadge.forUnitStatus(unit.status)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

struct ServiceRequestRow: View {
    let request: ServiceRequest

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(request.subject)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.brandCharcoal)
                    .lineLimit(1)
                Text(request.caseNumber)
                    .font(.caption)
                    .foregroundStyle(.brandGray)
            }
            Spacer()
            StatusBadge.forServiceStatus(request.status)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
