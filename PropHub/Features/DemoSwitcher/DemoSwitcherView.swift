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

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 14) {
                // Developer Logo
                ZStack {
                    Circle()
                        .fill(Color(hex: project.brandPrimaryColor).opacity(0.1))
                        .frame(width: 64, height: 64)

                    KFImage(URL(string: project.logoUrl))
                        .placeholder {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(Color(hex: project.brandPrimaryColor))
                        }
                        .onFailure { _ in }
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(spacing: 4) {
                    Text(project.developer.uppercased())
                        .font(.system(size: 9, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(.brandGray)
                        .lineLimit(1)

                    Text(project.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.brandCharcoal)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    if let count = project.unitCount {
                        Text("\(count) units")
                            .font(.caption2)
                            .foregroundStyle(.brandGold)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(hex: project.brandPrimaryColor).opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(project.developer) \(project.name)")
    }
}
