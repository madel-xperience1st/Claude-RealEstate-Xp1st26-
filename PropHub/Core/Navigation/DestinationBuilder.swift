import SwiftUI

/// Shared destination builder for NavigationStack routing.
/// Used by all tabs that support AppRouter.Destination navigation.
@ViewBuilder
func destinationView(for destination: AppRouter.Destination) -> some View {
    switch destination {
    case .unitDetail(let unit):
        UnitDetailView(unit: unit)
    case .installments(let unitId):
        InstallmentView(unitId: unitId)
    case .serviceRequests:
        ServiceRequestListContent()
    case .serviceRequestDetail(let requestId):
        ServiceRequestDetailView(requestId: requestId)
    case .assetList(let unitId):
        AssetListView(unitId: unitId)
    case .assetDetail(let asset):
        AssetDetailView(asset: asset)
    case .launchDetail(let launch):
        LaunchDetailView(launch: launch)
    }
}
