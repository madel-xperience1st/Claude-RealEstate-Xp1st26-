import Foundation
import Combine

/// Represents a connection to a specific Salesforce org via MuleSoft.
/// Stored encrypted in the iOS Keychain.
struct OrgConnection: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var muleBaseURL: String
    var orgId: String
    var isActive: Bool

    /// Creates a new org connection with a generated UUID.
    init(name: String, muleBaseURL: String, orgId: String, isActive: Bool = false) {
        self.id = UUID()
        self.name = name
        self.muleBaseURL = muleBaseURL
        self.orgId = orgId
        self.isActive = isActive
    }
}

/// Manages multiple Salesforce org connections for demo switching.
/// Persists connections securely in the Keychain and notifies observers on changes.
@MainActor
final class Environment: ObservableObject {
    static let shared = Environment()

    /// Notification posted when the active org connection changes.
    static let orgDidChangeNotification = Notification.Name("PropHub.orgDidChange")

    @Published var connections: [OrgConnection] = []
    @Published var activeConnection: OrgConnection

    private let secretsManager = SecretsManager.shared
    private static let connectionsKey = "prophub.org.connections"

    private init() {
        let defaultConnection = OrgConnection(
            name: NSLocalizedString("default_org_name", comment: ""),
            muleBaseURL: AppConfig.defaultMuleBaseURL,
            orgId: AppConfig.defaultOrgId,
            isActive: true
        )
        self.activeConnection = defaultConnection
        self.connections = [defaultConnection]
        loadConnections()
    }

    /// The base URL for the currently active MuleSoft API gateway.
    var muleBaseURL: String {
        activeConnection.muleBaseURL
    }

    /// Switches the active org, clears cached data, and notifies observers.
    func switchOrg(to connection: OrgConnection) {
        var updatedConnections = connections.map { conn -> OrgConnection in
            var mutable = conn
            mutable.isActive = (conn.id == connection.id)
            return mutable
        }

        if let index = updatedConnections.firstIndex(where: { $0.id == connection.id }) {
            activeConnection = updatedConnections[index]
        }

        connections = updatedConnections
        persistConnections()
        CacheManager.shared.clearAll()
        NotificationCenter.default.post(name: Self.orgDidChangeNotification, object: nil)
    }

    /// Adds a new org connection and persists it.
    func addConnection(_ connection: OrgConnection) {
        var newConnection = connection
        if connections.isEmpty {
            newConnection.isActive = true
            activeConnection = newConnection
        }
        connections.append(newConnection)
        persistConnections()
    }

    /// Updates an existing org connection.
    func updateConnection(_ connection: OrgConnection) {
        if let index = connections.firstIndex(where: { $0.id == connection.id }) {
            connections[index] = connection
            if connection.isActive {
                activeConnection = connection
            }
            persistConnections()
        }
    }

    /// Removes an org connection. Cannot remove the active connection.
    func removeConnection(_ connection: OrgConnection) {
        guard connection.id != activeConnection.id else { return }
        connections.removeAll { $0.id == connection.id }
        persistConnections()
    }

    // MARK: - Persistence

    private func persistConnections() {
        guard let data = try? JSONEncoder().encode(connections) else { return }
        secretsManager.save(data, forKey: Self.connectionsKey)
    }

    private func loadConnections() {
        guard let data = secretsManager.load(forKey: Self.connectionsKey),
              let saved = try? JSONDecoder().decode([OrgConnection].self, from: data) else {
            return
        }
        connections = saved
        if let active = saved.first(where: { $0.isActive }) {
            activeConnection = active
        }
    }
}
