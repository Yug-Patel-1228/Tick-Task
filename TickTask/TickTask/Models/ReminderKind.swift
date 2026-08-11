import Foundation

enum ReminderKind: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case atDueDate = "At Due Date"
    case dayBefore = "Day Before"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case specificDate = "Specific Date"

    var id: String { rawValue }

    func resolvedDate(dueDate: Date?, specificDate: Date?, now: Date = Date(), calendar: Calendar = .current) -> Date? {
        switch self {
        case .none:
            return nil
        case .atDueDate:
            return dueDate
        case .dayBefore:
            guard let dueDate else { return nil }
            return calendar.date(byAdding: .day, value: -1, to: dueDate)
        case .today:
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)
        case .tomorrow:
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else { return nil }
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow)
        case .specificDate:
            return specificDate
        }
    }
}
