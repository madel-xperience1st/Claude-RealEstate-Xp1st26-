import Foundation

/// Handles FCM token registration with MuleSoft.
final class NotificationService {
    static let shared = NotificationService()

    private let apiService = APIService.shared

    /// Registers the FCM device token with MuleSoft for push notification delivery.
    func registerToken(_ fcmToken: String) async {
        guard let contactId = UserSession.shared.contactId else { return }

        SecretsManager.shared.save(fcmToken, forKey: SecretsManager.Keys.fcmToken)

        do {
            let _: [String: Bool] = try await apiService.request(
                .registerPushToken(fcmToken: fcmToken, contactId: contactId)
            )
        } catch {
            print("[PropHub] FCM token registration failed: \(error.localizedDescription)")
        }
    }
}
