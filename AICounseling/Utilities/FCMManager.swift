import SwiftUI
import FirebaseMessaging

class FCMManager {
    static let shared = FCMManager()
    private let userDefaults = UserDefaults.standard
    private let fcmTokenRegisteredKey = "FCMTokenRegistered"
    
    func registerFCMTokenIfNeeded() {
        if !userDefaults.bool(forKey: fcmTokenRegisteredKey) {
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                } else if let token = token {
                    print("FCM registration token: \(token)")
                    self.userDefaults.set(true, forKey: self.fcmTokenRegisteredKey)
                }
            }
        }
    }
}
