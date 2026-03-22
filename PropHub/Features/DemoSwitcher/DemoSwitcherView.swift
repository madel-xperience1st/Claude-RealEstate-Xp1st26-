import SwiftUI
import Kingfisher

/// Grid view for selecting the active demo project.
/// Displayed after login and accessible from the navigation bar.
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
            ScrollView {
                if viewModel.projects.isEmpty && !viewModel.isLoading {
                    EmptyStateView(
                        icon: "folder.badge.questionmark",
                        title: NSLocalizedString("no_projects_title", comment: ""),
                        message: NSLocalizedString("no_projects_message", comment: ""),
                        actionTitle: NSLocalizedString("try_again", comment: ""),
                        action: { Task { await viewModel.loadProjects() } }
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.projects) { project in
                            DemoProjectCard(project: project) {
                                viewModel.selectProject(project)
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString("select_demo", comment: ""))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            // Navigate to org settings
                        } label: {
                            Label(
                                NSLocalizedString("org_settings", comment: ""),
                                systemImage: "server.rack"
                            )
                        }
                        Button(role: .destructive) {
                            Task { await authManager.signOut() }
                        } label: {
                            Label(
                                NSLocalizedString("sign_out", comment: ""),
                                systemImage: "rectangle.portrait.and.arrow.right"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .accessibilityLabel(NSLocalizedString("more_options", comment: ""))
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

/// Card displaying a demo project with its branding.
struct DemoProjectCard: View {
    let project: DemoProject
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Developer Logo
                KFImage(URL(string: project.logoUrl))
                    .placeholder {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color(hex: project.brandPrimaryColor))
                    }
                    .onFailure { _ in }
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                // Project Info
                VStack(spacing: 4) {
                    Text(project.developer)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text(project.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    if let count = project.unitCount {
                        Text(String(
                            format: NSLocalizedString("unit_count", comment: ""),
                            count
                        ))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: project.brandPrimaryColor).opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(project.developer) \(project.name)")
        .accessibilityHint(NSLocalizedString("select_demo_hint", comment: ""))
    }
}
