import SwiftUI

/// Premium dashboard — polished hero welcome, stat cards, and elegant sections.
struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var router: AppRouter
    @State private var showDemoSwitcher = false

    var body: some View {
        NavigationStack(path: $router.homePath) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    heroWelcomeCard
                    quickStatsSection
                    unitsSummarySection
                    paymentOverviewSection
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
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
    }

    // MARK: - Hero Welcome Card

    private var heroWelcomeCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Dynamic gradient using developer brand colors
            LinearGradient(
                colors: [
                    themeManager.primaryColor,
                    themeManager.primaryColor.opacity(0.85),
                    themeManager.primaryColor.opacity(0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 22))

            // Decorative elements
            GeometryReader { geo in
                Circle()
                    .fill(themeManager.secondaryColor.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .offset(x: geo.size.width - 80, y: 20)

                Circle()
                    .fill(themeManager.secondaryColor.opacity(0.06))
                    .frame(width: 120, height: 120)
                    .offset(x: geo.size.width - 40, y: -30)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 22))

            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome back")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.75))

                Text(themeManager.developerName)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(themeManager.secondaryColor)
                        .frame(width: 16, height: 3)
                    Text(themeManager.activeProject?.name ?? "Select a project")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(themeManager.secondaryColor)
                }
            }
            .padding(24)
        }
        .padding(.top, 8)
    }

    // MARK: - Quick Stats

    private var quickStatsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            Button {
                router.selectedTab = .units
            } label: {
                StatCard(
                    title: "Total Units",
                    value: "\(viewModel.totalUnits)",
                    icon: "building.2",
                    color: themeManager.primaryColor
                )
            }
            .buttonStyle(.plain)

            Button {
                router.navigateToServiceRequests()
            } label: {
                StatCard(
                    title: "Open Requests",
                    value: "\(viewModel.openServiceRequests)",
                    icon: "wrench.and.screwdriver",
                    color: themeManager.secondaryColor
                )
            }
            .buttonStyle(.plain)

            Button {
                if let unitId = viewModel.units.first?.id {
                    router.navigateToInstallments(unitId: unitId)
                }
            } label: {
                StatCard(
                    title: "Overdue",
                    value: "\(viewModel.overdueCount)",
                    icon: "exclamationmark.circle",
                    color: viewModel.overdueCount > 0 ? .brandCoral : .brandEmerald
                )
            }
            .buttonStyle(.plain)

            Button {
                if let unitId = viewModel.units.first?.id {
                    router.navigateToInstallments(unitId: unitId)
                }
            } label: {
                StatCard(
                    title: "Next Payment",
                    value: viewModel.nextPaymentDate?.mediumFormatted ?? "-",
                    icon: "calendar",
                    color: .brandSky
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Units Summary

    private var unitsSummarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "My Units", icon: "building.2.fill")

            if viewModel.units.isEmpty {
                Text("No units available")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.brandGray)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.units.prefix(3).enumerated()), id: \.element.id) { index, unit in
                        Button {
                            router.navigateToUnit(unit)
                        } label: {
                            UnitSummaryRow(unit: unit)
                        }
                        .buttonStyle(.plain)
                        if index < min(viewModel.units.count, 3) - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
                )
            }
        }
    }

    // MARK: - Payment Overview

    private var paymentOverviewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Payment Overview", icon: "creditcard.fill")

            if let summary = viewModel.paymentSummary {
                VStack(spacing: 0) {
                    PaymentRow(
                        label: "Total Price",
                        amount: summary.totalPrice,
                        currencyCode: themeManager.currencyCode,
                        color: .brandCharcoal
                    )
                    .padding(.vertical, 14)

                    Divider()

                    PaymentRow(
                        label: "Paid",
                        amount: summary.paidAmount,
                        currencyCode: themeManager.currencyCode,
                        color: .brandEmerald
                    )
                    .padding(.vertical, 14)

                    Divider()

                    PaymentRow(
                        label: "Remaining",
                        amount: summary.remainingBalance,
                        currencyCode: themeManager.currencyCode,
                        color: themeManager.secondaryColor
                    )
                    .padding(.vertical, 14)
                }
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
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
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.brandGray)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.recentServiceRequests.prefix(3).enumerated()), id: \.element.id) { index, request in
                        Button {
                            router.navigateToServiceRequestDetail(requestId: request.id)
                        } label: {
                            ServiceRequestRow(request: request)
                        }
                        .buttonStyle(.plain)
                        if index < min(viewModel.recentServiceRequests.count, 3) - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
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
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.brandGold)
            Text(title)
                .font(.system(size: 17, weight: .semibold))
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
                .font(.system(size: 15, weight: .regular))
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
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(color)
            }

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.brandCharcoal)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.brandGray)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
        )
        .accessibilityElement(children: .combine)
    }
}

struct UnitSummaryRow: View {
    let unit: Unit

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(unit.unitNumber)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.brandCharcoal)
                Text(unit.building)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.brandGray)
            }
            Spacer()
            StatusBadge.forUnitStatus(unit.status)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }
}

struct ServiceRequestRow: View {
    let request: ServiceRequest

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(request.subject)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.brandCharcoal)
                    .lineLimit(1)
                Text(request.caseNumber)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.brandGray)
            }
            Spacer()
            StatusBadge.forServiceStatus(request.status)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }
}
