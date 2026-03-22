import Foundation

/// Routes push notification deep links to the appropriate screen.
final class NotificationRouter: ObservableObject {
    static let shared = NotificationRouter()

    @Published var pendingDeepLink: DeepLink?

    enum DeepLink: Equatable {
        case paymentReminder(unitId: String, installmentId: String)
        case serviceUpdate(requestId: String)
        case newLaunch(launchId: String)
        case waitlistConfirmation(entryId: String)
    }

    /// Parses the notification payload and sets the pending deep link.
    func handle(userInfo: [AnyHashable: Any]) {
        guard let data = userInfo["data"] as? [String: Any] ?? userInfo as? [String: Any],
              let type = data["type"] as? String else { return }

        switch type {
        case "payment_reminder":
            if let unitId = data["unitId"] as? String,
               let installmentId = data["installmentId"] as? String {
                pendingDeepLink = .paymentReminder(unitId: unitId, installmentId: installmentId)
            }
        case "service_update":
            if let requestId = data["requestId"] as? String {
                pendingDeepLink = .serviceUpdate(requestId: requestId)
            }
        case "new_launch":
            if let launchId = data["launchId"] as? String {
                pendingDeepLink = .newLaunch(launchId: launchId)
            }
        case "waitlist_confirmation":
            if let entryId = data["entryId"] as? String {
                pendingDeepLink = .waitlistConfirmation(entryId: entryId)
            }
        default:
            break
        }
    }

    /// Clears the pending deep link after navigation.
    func clearPendingDeepLink() {
        pendingDeepLink = nil
    }
}
