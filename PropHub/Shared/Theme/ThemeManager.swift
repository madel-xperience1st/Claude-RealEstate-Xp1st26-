import SwiftUI

/// Manages dynamic theming based on the selected demo project's branding.
@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var primaryColor: Color = .brandNavy
    @Published var secondaryColor: Color = .brandGold
    @Published var logoURL: URL?
    @Published var developerName: String = "PropHub"
    @Published var activeProject: DemoProject?
    @Published var currencyCode: String = "AED"

    private init() {}

    func apply(project: DemoProject) {
        activeProject = project
        primaryColor = Color(hex: project.brandPrimaryColor)
        secondaryColor = Color(hex: project.brandSecondaryColor)
        logoURL = URL(string: project.logoUrl)
        developerName = project.developer
        currencyCode = project.defaultCurrency

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(primaryColor)
        ]
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(primaryColor)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    func reset() {
        activeProject = nil
        primaryColor = .brandNavy
        secondaryColor = .brandGold
        logoURL = nil
        developerName = "PropHub"
        currencyCode = "AED"
    }
}
