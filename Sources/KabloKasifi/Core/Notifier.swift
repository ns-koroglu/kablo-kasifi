import Foundation
import UserNotifications

/// Aygıt takıldığında bildirim gönderir. Uygulamanın asıl değeri
/// ("kablon sadece şarj kablosu") daha önce yalnızca panel açıksa görülüyordu.
@MainActor
enum Notifier {
    private static var authorized = false
    private static var asked = false

    static var isEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "notifyOnConnect") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "notifyOnConnect") }
    }

    static func requestIfNeeded() {
        guard isEnabled, !asked else { return }
        asked = true
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async { authorized = granted }
        }
    }

    static func deviceConnected(title: String, detail: String) {
        guard isEnabled else { return }
        requestIfNeeded()

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = detail
        content.sound = nil

        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
