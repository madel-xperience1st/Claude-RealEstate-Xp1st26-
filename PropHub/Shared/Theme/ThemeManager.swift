import SwiftUI

/// Manages dynamic theming based on the selected demo project's branding.
/// Updates colors, logos, and developer names throughout the app.
@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var primaryColor: Color = .blue
    @Published var secondaryColor: Color = .orange
    @Published var logoURL: URL?
    @Published var developerName: String = "PropHub"
    @Published var activeProject: DemoProject?
    @Published var currencyCode: String = "AED"

    private init() {}

    /// Applies branding from a demo project to the entire app.
    func apply(project: DemoProject) {
        activeProject = project
        primaryColor = Color(hex: project.brandPrimaryColor)
        secondaryColor = Color(hex: project.brandSecondaryColor)
        logoURL = URL(string: project.logoUrl)
        developerName = project.developer
        currencyCode = project.defaultCurrency

        // Update navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(primaryColor)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    /// Resets theming to defaults (called on sign-out or org switch).
    func reset() {
        activeProject = nil
        primaryColor = .blue
        secondaryColor = .orange
        logoURL = nil
        developerName = "PropHub"
        currencyCode = "AED"
    }
}
