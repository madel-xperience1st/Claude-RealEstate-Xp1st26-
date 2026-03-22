import SwiftUI

/// Displays a list of all units owned by the current demo contact.
struct UnitListView: View {
    @StateObject private var viewModel = UnitListViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showDemoSwitcher = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.units) { unit in
                    NavigationLink(destination: UnitDetailView(unit: unit)) {
                        UnitCardView(unit: unit)
                    }
                    .accessibilityLabel("\(unit.unitNumber), \(unit.building), \(unit.status)")
                }
            }
            .listStyle(.plain)
            .navigationTitle(NSLocalizedString("tab_units", comment: ""))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showDemoSwitcher = true
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .accessibilityLabel(NSLocalizedString("switch_demo", comment: ""))
                }
            }
            .sheet(isPresented: $showDemoSwitcher) {
                DemoSwitcherView()
            }
            .loading(viewModel.isLoading)
            .emptyState(
                viewModel.units.isEmpty && !viewModel.isLoading,
                icon: "building.2",
                title: NSLocalizedString("no_units_title", comment: ""),
                message: NSLocalizedString("no_units_message", comment: "")
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

/// Card view for a unit in the list.
struct UnitCardView: View {
    let unit: Unit
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(unit.unitNumber)
                    .font(.headline)
                Spacer()
                StatusBadge.forUnitStatus(unit.status)
            }

            HStack(spacing: 16) {
                Label(unit.building, systemImage: "building")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Label(
                    NSLocalizedString("floor_label", comment: "") + " \(unit.floor)",
                    systemImage: "arrow.up.to.line"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            HStack {
                Text(unit.unitType)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(unit.areaSqm)) sqm")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let handoverDate = unit.handoverDate {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(handoverDate.mediumFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Payment progress bar
            if let completion = unit.paymentCompletion {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(NSLocalizedString("payment_progress", comment: ""))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(completion * 100))%")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    ProgressView(value: completion)
                        .tint(themeManager.primaryColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
