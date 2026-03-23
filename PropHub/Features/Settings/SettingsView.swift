import SwiftUI

/// Premium settings screen with luxury styling.
struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var environment: Environment
    @StateObject private var settings = AppSettings.shared
    @State private var showOrgEditor = false
    @State private var showDemoSwitcher = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandWhite.ignoresSafeArea()

                List {
                    // User Profile Card
                    Section {
                        if let user = UserSession.shared.currentUser {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.brandNavy)
                                        .frame(width: 50, height: 50)
                                    Text(String(user.displayName.prefix(1)))
                                        .font(.title2.weight(.semibold))
                                        .foregroundStyle(.brandGold)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(user.displayName)
                                        .font(.headline)
                                        .foregroundStyle(.brandCharcoal)
                                    Text(user.email)
                                        .font(.caption)
                                        .foregroundStyle(.brandGray)
                                    if let role = user.role {
                                        Text(role.uppercased())
                                            .font(.system(size: 9, weight: .semibold))
                                            .tracking(1)
                                            .foregroundStyle(.brandGold)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }

                    // Demo Settings
                    Section("Demo") {
                        Toggle("Use Mock Data", isOn: $settings.useMockData)
                            .tint(.brandGold)

                        Toggle("Demo Auth", isOn: $settings.demoAuthEnabled)
                            .tint(.brandGold)

                        Button {
                            showDemoSwitcher = true
                        } label: {
                            HStack {
                                Label("Switch Project", systemImage: "arrow.triangle.2.circlepath")
                                    .foregroundStyle(.brandCharcoal)
                                Spacer()
                                if let project = themeManager.activeProject {
                                    Text(project.name)
                                        .font(.caption)
                                        .foregroundStyle(.brandGold)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.brandGray)
                            }
                        }
                    }

                    // Org Connections
                    Section("Organizations") {
                        ForEach(environment.connections) { connection in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(connection.name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.brandCharcoal)
                                    Text(connection.muleBaseURL)
                                        .font(.caption2)
                                        .foregroundStyle(.brandGray)
                                        .lineLimit(1)
                                }
                                Spacer()
                                if connection.isActive {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.brandEmerald)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                environment.switchOrg(to: connection)
                            }
                        }

                        Button {
                            showOrgEditor = true
                        } label: {
                            Label("Add Organization", systemImage: "plus.circle")
                                .foregroundStyle(.brandNavy)
                        }
                    }

                    // App Info
                    Section("About") {
                        HStack {
                            Text("Version")
                                .foregroundStyle(.brandCharcoal)
                            Spacer()
                            Text("\(AppConfig.appVersion) (\(AppConfig.buildNumber))")
                                .foregroundStyle(.brandGray)
                        }
                        HStack {
                            Text("Cache")
                                .foregroundStyle(.brandCharcoal)
                            Spacer()
                            Button("Clear") {
                                CacheManager.shared.clearAll()
                            }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.brandCoral)
                        }
                    }

                    // Sign Out
                    Section {
                        Button(role: .destructive) {
                            Task { await authManager.signOut() }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sign Out")
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showOrgEditor) { OrgEditorView() }
            .sheet(isPresented: $showDemoSwitcher) { DemoSwitcherView() }
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
                Section("Organization Details") {
                    TextField("Name", text: $name)
                    TextField("MuleSoft Base URL", text: $muleBaseURL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                    TextField("Org ID", text: $orgId)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Add Organization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.brandGray)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let connection = OrgConnection(name: name, muleBaseURL: muleBaseURL, orgId: orgId)
                        environment.addConnection(connection)
                        dismiss()
                    }
                    .disabled(name.isEmpty || muleBaseURL.count < 10)
                    .fontWeight(.semibold)
                    .foregroundStyle(.brandNavy)
                }
            }
        }
    }
}
