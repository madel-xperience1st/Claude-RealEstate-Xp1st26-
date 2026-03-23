import SwiftUI
import Kingfisher

/// Premium demo project selector — card grid with luxury styling.
struct DemoSwitcherView: View {
    @StateObject private var viewModel = DemoSwitcherViewModel()
    @EnvironmentObject var authManager: AuthManager
    @SwiftUI.Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandWhite.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    if viewModel.projects.isEmpty && !viewModel.isLoading {
                        EmptyStateView(
                            icon: "folder.badge.questionmark",
                            title: "No Projects",
                            message: "No demo projects available. Pull to refresh.",
                            actionTitle: "Retry",
                            action: { Task { await viewModel.loadProjects() } }
                        )
                    } else {
                        VStack(spacing: 20) {
                            // Header subtitle
                            Text("SELECT YOUR EXPERIENCE")
                                .font(.system(size: 11, weight: .medium))
                                .tracking(3)
                                .foregroundStyle(.brandGold)
                                .padding(.top, 8)

                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.projects) { project in
                                    DemoProjectCard(project: project) {
                                        viewModel.selectProject(project)
                                        dismiss()
                                    }
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                        } label: {
                            Label("Org Settings", systemImage: "server.rack")
                        }
                        Button(role: .destructive) {
                            Task { await authManager.signOut() }
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.brandNavy)
                    }
                }
            }
            .loading(viewModel.isLoading)
            .errorAlert(error: $viewModel.error) {
                Task { await viewModel.loadProjects() }
            }
            .task {
                await viewModel.loadProjects()
            }
        }
    }
}

/// Premium project card with brand colors and elegant styling.
struct DemoProjectCard: View {
    let project: DemoProject
    let onSelect: () -> Void

    private var primaryColor: Color { Color(hex: project.brandPrimaryColor) }
    private var secondaryColor: Color { Color(hex: project.brandSecondaryColor) }

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 0) {
                // Mini hero gradient
                ZStack {
                    LinearGradient(
                        colors: [primaryColor, primaryColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 80)

                    // Decorative circle
                    Circle()
                        .fill(secondaryColor.opacity(0.12))
                        .frame(width: 60, height: 60)
                        .offset(x: 40, y: -10)

                    Image(systemName: project.developerIcon ?? "building.2.fill")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(secondaryColor.opacity(0.6))
                }
                .clipShape(
                    UnevenRoundedRectangle(topLeadingRadius: 18, topTrailingRadius: 18)
                )

                VStack(spacing: 6) {
                    Text(project.developer.uppercased())
                        .font(.system(size: 9, weight: .semibold))
                        .tracking(2)
                        .foregroundStyle(.brandGray)
                        .lineLimit(1)

                    Text(project.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.brandCharcoal)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    if let count = project.unitCount {
                        Text("\(count) units")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(secondaryColor)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
            }
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 14, y: 6)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(project.developer) \(project.name)")
    }
}
