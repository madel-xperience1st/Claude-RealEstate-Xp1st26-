import SwiftUI

/// App settings screen with org management, demo mode toggle, and account actions.
struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var environment: Environment
    @StateObject private var settings = AppSettings.shared
    @State private var showOrgEditor = false
    @State private var showDemoSwitcher = false

    var body: some View {
        NavigationStack {
            List {
                // User Info
                Section {
                    if let user = UserSession.shared.currentUser {
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(themeManager.primaryColor)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.displayName)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let role = user.role {
                                    Text(role)
                                        .font(.caption2)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // Demo Settings
                Section(NSLocalizedString("settings_demo_section", comment: "")) {
                    Toggle(
                        NSLocalizedString("settings_mock_data", comment: ""),
                        isOn: $settings.useMockData
                    )
                    .accessibilityLabel(NSLocalizedString("settings_mock_data", comment: ""))

                    Toggle(
                        NSLocalizedString("settings_demo_auth", comment: ""),
                        isOn: $settings.demoAuthEnabled
                    )
                    .accessibilityLabel(NSLocalizedString("settings_demo_auth", comment: ""))

                    Button {
                        showDemoSwitcher = true
                    } label: {
                        HStack {
                            Label(
                                NSLocalizedString("switch_demo", comment: ""),
                                systemImage: "arrow.triangle.2.circlepath"
                            )
                            Spacer()
                            if let project = themeManager.activeProject {
                                Text(project.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Org Connections
                Section(NSLocalizedString("settings_orgs_section", comment: "")) {
                    ForEach(environment.connections) { connection in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(connection.name)
                                    .font(.subheadline)
                                Text(connection.muleBaseURL)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            if connection.isActive {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            environment.switchOrg(to: connection)
                        }
                        .accessibilityLabel("\(connection.name), \(connection.isActive ? "active" : "inactive")")
                    }

                    Button {
                        showOrgEditor = true
                    } label: {
                        Label(
                            NSLocalizedString("settings_add_org", comment: ""),
                            systemImage: "plus.circle"
                        )
                    }
                }

                // App Info
                Section(NSLocalizedString("settings_about_section", comment: "")) {
                    HStack {
                        Text(NSLocalizedString("settings_version", comment: ""))
                        Spacer()
                        Text("\(AppConfig.appVersion) (\(AppConfig.buildNumber))")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(NSLocalizedString("settings_cache", comment: ""))
                        Spacer()
                        Button(NSLocalizedString("settings_clear_cache", comment: "")) {
                            CacheManager.shared.clearAll()
                        }
                        .font(.caption)
                    }
                }

                // Sign Out
                Section {
                    Button(role: .destructive) {
                        Task { await authManager.signOut() }
                    } label: {
                        HStack {
                            Spacer()
                            Text(NSLocalizedString("sign_out", comment: ""))
                                .fontWeight(.medium)
                            Spacer()
                        }
                    }
                    .accessibilityLabel(NSLocalizedString("sign_out", comment: ""))
                }
            }
            .navigationTitle(NSLocalizedString("settings_title", comment: ""))
            .sheet(isPresented: $showOrgEditor) {
                OrgEditorView()
            }
            .sheet(isPresented: $showDemoSwitcher) {
                DemoSwitcherView()
            }
        }
    }
}

/// Form for adding a new org connection.
struct OrgEditorView: View {
    @EnvironmentObject var environment: Environment
    @SwiftUI.Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var muleBaseURL = "https://"
    @State private var orgId = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("org_details_section", comment: "")) {
                    TextField(NSLocalizedString("org_name_label", comment: ""), text: $name)
                        .accessibilityLabel(NSLocalizedString("org_name_label", comment: ""))
                    TextField(NSLocalizedString("org_mule_url_label", comment: ""), text: $muleBaseURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .accessibilityLabel(NSLocalizedString("org_mule_url_label", comment: ""))
                    TextField(NSLocalizedString("org_id_label", comment: ""), text: $orgId)
                        .autocapitalization(.none)
                        .accessibilityLabel(NSLocalizedString("org_id_label", comment: ""))
                }
            }
            .navigationTitle(NSLocalizedString("settings_add_org", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(NSLocalizedString("cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(NSLocalizedString("settings_save", comment: "")) {
                        let connection = OrgConnection(
                            name: name,
                            muleBaseURL: muleBaseURL,
                            orgId: orgId
                        )
                        environment.addConnection(connection)
                        dismiss()
                    }
                    .disabled(name.isEmpty || muleBaseURL.count < 10)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
