import SwiftUI

/// Centralized navigation router enabling cross-tab navigation and deep link handling.
@MainActor
final class AppRouter: ObservableObject {
    static let shared = AppRouter()

    /// Currently selected tab in MainTabView.
    @Published var selectedTab: Tab = .home

    /// Navigation path for each tab's NavigationStack.
    @Published var homePath = NavigationPath()
    @Published var unitsPath = NavigationPath()
    @Published var conciergePath = NavigationPath()
    @Published var launchesPath = NavigationPath()
    @Published var settingsPath = NavigationPath()

    enum Tab: Int, CaseIterable {
        case home, units, concierge, launches, settings
    }

    // MARK: - Navigation Destinations

    /// All possible navigation destinations in the app.
    enum Destination: Hashable {
        case unitDetail(Unit)
        case installments(unitId: String)
        case serviceRequests
        case serviceRequestDetail(requestId: String)
        case assetList(unitId: String)
        case assetDetail(Asset)
        case launchDetail(ProjectLaunch)
    }

    // MARK: - Cross-Tab Navigation

    /// Navigate to a specific unit's detail from any tab.
    func navigateToUnit(_ unit: Unit) {
        unitsPath = NavigationPath()
        unitsPath.append(Destination.unitDetail(unit))
        selectedTab = .units
    }

    /// Navigate to installments for a unit.
    func navigateToInstallments(unitId: String) {
        unitsPath = NavigationPath()
        if let unit = findUnit(unitId) {
            unitsPath.append(Destination.unitDetail(unit))
            unitsPath.append(Destination.installments(unitId: unitId))
        }
        selectedTab = .units
    }

    /// Navigate to service requests tab.
    func navigateToServiceRequests() {
        unitsPath = NavigationPath()
        if let unit = MockDataProvider.units.first {
            unitsPath.append(Destination.unitDetail(unit))
            unitsPath.append(Destination.serviceRequests)
        }
        selectedTab = .units
    }

    /// Navigate to a specific service request detail.
    func navigateToServiceRequestDetail(requestId: String) {
        unitsPath = NavigationPath()
        if let unit = MockDataProvider.units.first {
            unitsPath.append(Destination.unitDetail(unit))
            unitsPath.append(Destination.serviceRequests)
            unitsPath.append(Destination.serviceRequestDetail(requestId: requestId))
        }
        selectedTab = .units
    }

    /// Navigate to a specific launch.
    func navigateToLaunch(_ launch: ProjectLaunch) {
        launchesPath = NavigationPath()
        launchesPath.append(Destination.launchDetail(launch))
        selectedTab = .launches
    }

    /// Navigate to asset list for a unit.
    func navigateToAssets(unitId: String) {
        unitsPath = NavigationPath()
        if let unit = findUnit(unitId) {
            unitsPath.append(Destination.unitDetail(unit))
            unitsPath.append(Destination.assetList(unitId: unitId))
        }
        selectedTab = .units
    }

    /// Pop to root for the current tab.
    func popToRoot() {
        switch selectedTab {
        case .home: homePath = NavigationPath()
        case .units: unitsPath = NavigationPath()
        case .concierge: conciergePath = NavigationPath()
        case .launches: launchesPath = NavigationPath()
        case .settings: settingsPath = NavigationPath()
        }
    }

    // MARK: - Deep Link Handling

    /// Processes a deep link from NotificationRouter and navigates accordingly.
    func handleDeepLink(_ deepLink: NotificationRouter.DeepLink) {
        switch deepLink {
        case .paymentReminder(let unitId, _):
            navigateToInstallments(unitId: unitId)

        case .serviceUpdate(let requestId):
            navigateToServiceRequestDetail(requestId: requestId)

        case .newLaunch(let launchId):
            if let launch = MockDataProvider.projectLaunches.first(where: { $0.id == launchId }) {
                navigateToLaunch(launch)
            } else {
                selectedTab = .launches
            }

        case .waitlistConfirmation:
            selectedTab = .launches
        }
    }

    // MARK: - Helpers

    private func findUnit(_ unitId: String) -> Unit? {
        MockDataProvider.units.first { $0.id == unitId }
    }
}
