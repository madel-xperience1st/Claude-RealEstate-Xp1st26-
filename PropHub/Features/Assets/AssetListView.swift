import SwiftUI

/// List of registered assets for a delivered unit.
struct AssetListView: View {
    let unitId: String
    @StateObject private var viewModel = AssetViewModel()

    var body: some View {
        List {
            ForEach(viewModel.assets) { asset in
                NavigationLink(destination: AssetDetailView(asset: asset, viewModel: viewModel)) {
                    AssetRow(asset: asset)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(NSLocalizedString("assets_title", comment: ""))
        .loading(viewModel.isLoading)
        .emptyState(
            viewModel.assets.isEmpty && !viewModel.isLoading,
            icon: "shippingbox",
            title: NSLocalizedString("no_assets_title", comment: ""),
            message: NSLocalizedString("no_assets_message", comment: "")
        )
        .errorAlert(error: $viewModel.error) {
            Task { await viewModel.loadAssets(unitId: unitId) }
        }
        .task {
            await viewModel.loadAssets(unitId: unitId)
        }
    }
}

/// Row for an asset in the list.
struct AssetRow: View {
    let asset: Asset

    var body: some View {
        HStack {
            Image(systemName: iconForCategory(asset.category))
                .font(.title3)
                .foregroundStyle(colorForWarrantyStatus(asset.warrantyStatus))
                .frame(width: 32)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let manufacturer = asset.manufacturer {
                    Text(manufacturer)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(
                    text: asset.warrantyStatus,
                    color: colorForWarrantyStatus(asset.warrantyStatus)
                )
                if let endDate = asset.warrantyEndDate {
                    Text(endDate.mediumFormatted)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "hvac": return "thermometer.medium"
        case "appliance": return "refrigerator"
        case "plumbing": return "drop"
        case "electrical": return "bolt"
        case "furniture": return "sofa"
        default: return "shippingbox"
        }
    }

    private func colorForWarrantyStatus(_ status: String) -> Color {
        switch status.lowercased() {
        case "active": return .green
        case "expiring soon": return .orange
        case "expired": return .red
        default: return .gray
        }
    }
}
