import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleNotification(for task: Task, calendar: Calendar = .current) {
        cancelNotification(for: task)

        guard !task.isCompleted,
              let reminderDate = task.reminder.resolvedDate(dueDate: task.dueDate, specificDate: task.reminderDate, calendar: calendar),
              reminderDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = task.title
        content.body = notificationBody(for: task, reminderDate: reminderDate)
        content.sound = .default

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: identifier(for: task), content: content, trigger: trigger)

        center.add(request)
    }

    func cancelNotification(for task: Task) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: task)])
    }

    func identifier(for task: Task) -> String {
        "task-\(task.id.uuidString)"
    }

    private func notificationBody(for task: Task, reminderDate: Date) -> String {
        if let dueDate = task.dueDate {
            return "Due \(dueDate.formatted(date: .abbreviated, time: .shortened))"
        }

        return "Reminder set for \(reminderDate.formatted(date: .abbreviated, time: .shortened))"
    }
}
