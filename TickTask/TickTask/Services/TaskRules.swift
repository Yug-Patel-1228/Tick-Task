import Foundation

struct DashboardSummary: Equatable {
    let completed: Int
    let pending: Int
    let dueToday: Int
    let overdue: Int
}

struct TaskStatistics: Equatable {
    let total: Int
    let completed: Int
    let pending: Int
    let completionRate: Double
    let currentStreak: Int
    let longestStreak: Int
}

enum TaskRules {
    static func matchesSearch(_ task: Task, searchText: String) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }

        return task.title.localizedCaseInsensitiveContains(query)
        || task.notes.localizedCaseInsensitiveContains(query)
        || task.category.rawValue.localizedCaseInsensitiveContains(query)
    }

    static func matchesFilter(_ task: Task, filter: TaskFilter, now: Date = Date(), calendar: Calendar = .current) -> Bool {
        switch filter {
        case .all:
            return true
        case .today:
            guard let dueDate = task.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: now)
        case .upcoming:
            guard let dueDate = task.dueDate, !task.isCompleted else { return false }
            return dueDate > calendar.startOfDay(for: now) && !calendar.isDate(dueDate, inSameDayAs: now)
        case .completed:
            return task.isCompleted
        case .overdue:
            guard let dueDate = task.dueDate, !task.isCompleted else { return false }
            return dueDate < now
        }
    }

    static func filteredAndSorted(
        tasks: [Task],
        searchText: String,
        filter: TaskFilter,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [Task] {
        tasks
            .filter { matchesSearch($0, searchText: searchText) && matchesFilter($0, filter: filter, now: now, calendar: calendar) }
            .sorted { lhs, rhs in
                if lhs.isPinned != rhs.isPinned {
                    return lhs.isPinned && !rhs.isPinned
                }

                switch (lhs.dueDate, rhs.dueDate) {
                case let (left?, right?) where left != right:
                    return left < right
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                default:
                    return lhs.createdAt > rhs.createdAt
                }
            }
    }

    static func dashboardSummary(tasks: [Task], now: Date = Date(), calendar: Calendar = .current) -> DashboardSummary {
        DashboardSummary(
            completed: tasks.filter(\.isCompleted).count,
            pending: tasks.filter { !$0.isCompleted }.count,
            dueToday: tasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return calendar.isDate(dueDate, inSameDayAs: now)
            }.count,
            overdue: tasks.filter { matchesFilter($0, filter: .overdue, now: now, calendar: calendar) }.count
        )
    }

    static func statistics(tasks: [Task], now: Date = Date(), calendar: Calendar = .current) -> TaskStatistics {
        let completedTasks = tasks.filter(\.isCompleted)
        let total = tasks.count
        let completed = completedTasks.count
        let completedDays = Set(completedTasks.map { task in
            calendar.startOfDay(for: task.completedAt ?? task.createdAt)
        })

        return TaskStatistics(
            total: total,
            completed: completed,
            pending: total - completed,
            completionRate: total == 0 ? 0 : Double(completed) / Double(total),
            currentStreak: currentStreak(completedDays: completedDays, now: now, calendar: calendar),
            longestStreak: longestStreak(completedDays: completedDays, calendar: calendar)
        )
    }

    static func duplicate(of task: Task) -> Task {
        Task(
            title: task.title,
            notes: task.notes,
            dueDate: task.dueDate,
            priority: task.priority,
            category: task.category,
            color: task.color,
            isCompleted: false,
            isPinned: task.isPinned,
            recurrence: task.recurrence,
            reminder: task.reminder,
            reminderDate: task.reminderDate
        )
    }

    static func nextOccurrence(from task: Task, now: Date = Date(), calendar: Calendar = .current) -> Task? {
        guard task.recurrence != .never, let dueDate = task.dueDate else {
            return nil
        }

        var nextDate = dueDate
        var attempts = 0
        repeat {
            guard let candidateDate = task.recurrence.nextDate(after: nextDate, calendar: calendar) else {
                return nil
            }

            nextDate = candidateDate
            attempts += 1
        } while nextDate <= now && attempts < 500

        guard nextDate > now else { return nil }

        let nextReminderDate: Date?
        if let reminderDate = task.reminderDate, let interval = calendar.dateComponents([.second], from: dueDate, to: reminderDate).second {
            nextReminderDate = calendar.date(byAdding: .second, value: interval, to: nextDate)
        } else {
            nextReminderDate = nil
        }

        return Task(
            title: task.title,
            notes: task.notes,
            dueDate: nextDate,
            priority: task.priority,
            category: task.category,
            color: task.color,
            isCompleted: false,
            isPinned: task.isPinned,
            recurrence: task.recurrence,
            reminder: task.reminder,
            reminderDate: nextReminderDate
        )
    }

    static func hasEquivalentOccurrence(_ candidate: Task, in tasks: [Task], calendar: Calendar = .current) -> Bool {
        tasks.contains { task in
            guard task.id != candidate.id,
                  !task.isCompleted,
                  task.title == candidate.title,
                  task.category == candidate.category,
                  task.recurrence == candidate.recurrence,
                  let leftDate = task.dueDate,
                  let rightDate = candidate.dueDate else {
                return false
            }

            return calendar.isDate(leftDate, inSameDayAs: rightDate)
        }
    }

    private static func currentStreak(completedDays: Set<Date>, now: Date, calendar: Calendar) -> Int {
        var streak = 0
        var day = calendar.startOfDay(for: now)

        while completedDays.contains(day) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }

        return streak
    }

    private static func longestStreak(completedDays: Set<Date>, calendar: Calendar) -> Int {
        let orderedDays = completedDays.sorted()
        var longest = 0
        var current = 0
        var previous: Date?

        for day in orderedDays {
            if let previous, calendar.dateComponents([.day], from: previous, to: day).day == 1 {
                current += 1
            } else {
                current = 1
            }

            longest = max(longest, current)
            previous = day
        }

        return longest
    }
}
