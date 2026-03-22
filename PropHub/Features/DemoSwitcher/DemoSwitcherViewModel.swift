import Foundation

/// View model for the demo project selector screen.
/// Fetches available demo projects from MuleSoft or uses mock data in demo mode.
@MainActor
final class DemoSwitcherViewModel: ObservableObject {
    @Published var projects: [DemoProject] = []
    @Published var isLoading = false
    @Published var error: APIError?

    private let apiService = APIService.shared
    private let themeManager = ThemeManager.shared
    private let userSession = UserSession.shared
    private let settings = AppSettings.shared

    /// Fetches all available demo projects.
    func loadProjects() async {
        isLoading = true
        error = nil

        if settings.useMockData {
            try? await Task.sleep(nanoseconds: 300_000_000)
            projects = MockDataProvider.demoProjects
            isLoading = false
            return
        }

        do {
            let fetchedProjects: [DemoProject] = try await apiService.request(
                .listProjects,
                cacheKey: "projects.list"
            )
            projects = fetchedProjects.filter { $0.status == "Active" }
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    /// Selects a demo project and applies its branding throughout the app.
    func selectProject(_ project: DemoProject) {
        themeManager.apply(project: project)
        userSession.setActiveProject(project.id)
        CacheManager.shared.clearAll()
    }
}
