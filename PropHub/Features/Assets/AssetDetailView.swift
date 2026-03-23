import SwiftUI

/// Detailed view of a single asset with warranty and maintenance information.
struct AssetDetailView: View {
    let asset: Asset
    @StateObject private var viewModel = AssetViewModel()
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Asset Info Header
            VStack(spacing: 8) {
                Text(asset.name)
                    .font(.title2)
                    .fontWeight(.bold)
                if let serial = asset.serialNumber {
                    Text("S/N: \(serial)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                StatusBadge(
                    text: asset.warrantyStatus,
                    color: warrantyColor
                )
            }
            .padding()

            Picker("", selection: $selectedTab) {
                Text(NSLocalizedString("warranty_tab", comment: "")).tag(0)
                Text(NSLocalizedString("maintenance_tab", comment: "")).tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch selectedTab {
            case 0:
                WarrantyView(asset: asset, warranty: viewModel.warranty)
            case 1:
                MaintenanceScheduleView(records: viewModel.maintenanceRecords, assetId: asset.id)
            default:
                WarrantyView(asset: asset, warranty: viewModel.warranty)
            }
        }
        .navigationTitle(asset.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadWarranty(assetId: asset.id)
            await viewModel.loadMaintenance(assetId: asset.id)
        }
    }

    private var warrantyColor: Color {
        switch asset.warrantyStatus.lowercased() {
        case "active": return .green
        case "expiring soon": return .orange
        case "expired": return .red
        default: return .gray
        }
    }
}
