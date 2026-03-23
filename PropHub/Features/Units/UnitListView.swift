import SwiftUI

/// Premium unit list with card-based layout.
struct UnitListView: View {
    @StateObject private var viewModel = UnitListViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showDemoSwitcher = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandWhite.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.units) { unit in
                            NavigationLink(destination: UnitDetailView(unit: unit)) {
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
                            .foregroundStyle(.brandNavy)
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
        }
    }
}

/// Premium unit card with clean layout and progress indicator.
struct UnitCardView: View {
    let unit: Unit
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(unit.unitNumber)
                        .font(.headline)
                        .foregroundStyle(.brandCharcoal)
                    Text(unit.building)
                        .font(.caption)
                        .foregroundStyle(.brandGray)
                }
                Spacer()
                StatusBadge.forUnitStatus(unit.status)
            }

            Divider()

            // Details grid
            HStack(spacing: 0) {
                unitDetail(icon: "arrow.up.to.line", label: "Floor \(unit.floor)")
                Spacer()
                unitDetail(icon: "square.split.2x2", label: unit.unitType)
                Spacer()
                unitDetail(icon: "ruler", label: "\(Int(unit.areaSqm)) sqm")
            }

            if let handoverDate = unit.handoverDate {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundStyle(.brandGold)
                    Text("Handover: \(handoverDate.mediumFormatted)")
                        .font(.caption)
                        .foregroundStyle(.brandGray)
                }
            }

            // Payment progress
            if let completion = unit.paymentCompletion {
                VStack(spacing: 6) {
                    HStack {
                        Text("Payment")
                            .font(.caption2)
                            .foregroundStyle(.brandGray)
                        Spacer()
                        Text("\(Int(completion * 100))%")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(themeManager.primaryColor)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.brandPlatinum)
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.goldGradient)
                                .frame(width: geo.size.width * completion, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
    }

    private func unitDetail(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(.brandGold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.brandCharcoal)
        }
    }
}
