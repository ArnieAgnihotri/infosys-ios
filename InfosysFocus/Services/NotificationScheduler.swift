import Foundation
import UserNotifications

final class NotificationScheduler {
    private let center = UNUserNotificationCenter.current()
    private let timerNotificationId = "infosys-focus.timer-finished"

    func requestPermission() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleTimerFinishedNotification(after seconds: Int, modeTitle: String) async {
        await requestPermission()
        center.removePendingNotificationRequests(withIdentifiers: [timerNotificationId])

        let content = UNMutableNotificationContent()
        content.title = "\(modeTitle) finished"
        content.body = "Time to move to the next block."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(max(1, seconds)), repeats: false)
        let request = UNNotificationRequest(identifier: timerNotificationId, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelTimerNotification() {
        center.removePendingNotificationRequests(withIdentifiers: [timerNotificationId])
    }
}
