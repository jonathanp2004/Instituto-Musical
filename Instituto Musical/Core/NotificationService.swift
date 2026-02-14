//
//  NotificationService.swift
//  Instituto Musical
//
//  Manages local push notifications for daily practice reminders.
//

import UserNotifications
import Foundation

final class NotificationService {

    static let shared = NotificationService()

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("⚠️ Notification permission error: \(error)")
            }
            print(granted ? "✅ Notifications granted" : "❌ Notifications denied")
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🎵 ¡Hora de practicar!"
        content.body = "El Mundo Sonoro te espera. ¡No pierdas tu racha!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("⚠️ Failed to schedule notification: \(error)")
            }
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
