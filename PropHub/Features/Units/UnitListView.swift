import SwiftUI

/// Premium unit list with card-based layout and centralized routing.
struct UnitListView: View {
    @StateObject private var viewModel = UnitListViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var router: AppRouter
    @State private var showDemoSwitcher = false

    var body: some View {
        NavigationStack(path: $router.unitsPath) {
            ZStack {
                Color.brandWhite.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.units) { unit in
                            NavigationLink(value: AppRouter.Destination.unitDetail(unit)) {
                                UnitCardView(unit: unit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("My Units")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showDemoSwitcher = true } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(themeManager.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showDemoSwitcher) {
                DemoSwitcherView()
            }
            .loading(viewModel.isLoading)
            .emptyState(
                viewModel.units.isEmpty && !viewModel.isLoading,
                icon: "building.2",
                title: "No Units",
                message: "No units found for this project."
            )
            .errorAlert(error: $viewModel.error) {
                Task { await viewModel.loadUnits() }
            }
            .refreshable {
                await viewModel.loadUnits()
            }
            .task {
                await viewModel.loadUnits()
            }
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
    }
}

/// Premium unit card with hero image area and clean layout.
struct UnitCardView: View {
    let unit: Unit
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Hero image area
            UnitHeroCard(unit: unit)

            VStack(alignment: .leading, spacing: 12) {
                // Status row
                HStack {
                    StatusBadge.forUnitStatus(unit.status)
                    Spacer()
                    if let handoverDate = unit.handoverDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                                .foregroundStyle(themeManager.secondaryColor)
                            Text(handoverDate.mediumFormatted)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.brandGray)
                        }
                    }
                }

                // Details row
                HStack(spacing: 16) {
                    unitDetail(icon: "arrow.up.to.line", label: "Floor \(unit.floor)")
                    unitDetail(icon: "square.split.2x2", label: unit.unitType)
                    unitDetail(icon: "ruler", label: "\(Int(unit.areaSqm)) sqm")
                    Spacer()
                }

                // Payment progress
                if let completion = unit.paymentCompletion {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Payment")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.brandGray)
                            Spacer()
                            Text("\(Int(completion * 100))%")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(themeManager.primaryColor)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.brandPlatinum)
                                    .frame(height: 5)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(
                                        LinearGradient(
                                            colors: [themeManager.primaryColor, themeManager.secondaryColor],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * completion, height: 5)
                            }
                        }
                        .frame(height: 5)
                    }
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func unitDetail(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(themeManager.secondaryColor)
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.brandCharcoal)
        }
    }
}
