import UIKit
import FirebaseAuth
import FirebaseMessaging
import UserNotifications

/// Application delegate handling Firebase initialization and push notification setup.
class AppDelegate: NSObject, UIApplicationDelegate {

    /// Configures Firebase and registers for remote notifications on app launch.
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        configureNotifications(application: application)
        Messaging.messaging().delegate = self
        return true
    }

    /// Forwards the device token to Firebase Messaging.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    /// Logs failures to register for remote notifications.
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("[PropHub] Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: - Private

    private func configureNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("[PropHub] Notification authorization error: \(error.localizedDescription)")
            }
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    /// Handles notifications received while the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }

    /// Handles user interaction with a notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        NotificationRouter.shared.handle(userInfo: userInfo)
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {

    /// Called when the FCM registration token is refreshed.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        Task {
            await NotificationService.shared.registerToken(token)
        }
    }
}
