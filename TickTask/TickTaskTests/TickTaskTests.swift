import Foundation
import SwiftData
import Testing
@testable import TickTask

@MainActor
struct TickTaskTests {
    private let calendar = Calendar(identifier: .gregorian)

    @Test func taskCreationEditingDeletionAndDuplicationRules() {
        let dueDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 11, hour: 10))!
        let task = Task(title: "Study SwiftData", notes: "Models", dueDate: dueDate, priority: .high, category: .study)

        #expect(task.title == "Study SwiftData")
        #expect(task.notes == "Models")
        #expect(task.dueDate == dueDate)
        #expect(task.priority == .high)
        #expect(task.category == .study)
        #expect(!task.isCompleted)

        task.title = "Study SwiftData V2"
        task.isCompleted = true
        task.completedAt = dueDate

        #expect(task.title == "Study SwiftData V2")
        #expect(task.isCompleted)
        #expect(task.completedAt == dueDate)

        let duplicate = TaskRules.duplicate(of: task)
        #expect(duplicate.id != task.id)
        #expect(duplicate.title == task.title)
        #expect(!duplicate.isCompleted)
    }

    @Test func searchMatchesTitleNotesAndCategory() {
        let task = Task(title: "Buy milk", notes: "Organic", category: .shopping)

        #expect(TaskRules.matchesSearch(task, searchText: "buy"))
        #expect(TaskRules.matchesSearch(task, searchText: "organic"))
        #expect(TaskRules.matchesSearch(task, searchText: "shopping"))
        #expect(!TaskRules.matchesSearch(task, searchText: "workout"))
    }

    @Test func filtersClassifyTasksCorrectly() {
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 11, hour: 12))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!

        let todayTask = Task(title: "Today", dueDate: now)
        let overdueTask = Task(title: "Overdue", dueDate: yesterday)
        let upcomingTask = Task(title: "Upcoming", dueDate: tomorrow)
        let completedTask = Task(title: "Done", dueDate: yesterday, isCompleted: true, completedAt: now)

        #expect(TaskRules.matchesFilter(todayTask, filter: .today, now: now, calendar: calendar))
        #expect(TaskRules.matchesFilter(overdueTask, filter: .overdue, now: now, calendar: calendar))
        #expect(TaskRules.matchesFilter(upcomingTask, filter: .upcoming, now: now, calendar: calendar))
        #expect(TaskRules.matchesFilter(completedTask, filter: .completed, now: now, calendar: calendar))
        #expect(!TaskRules.matchesFilter(completedTask, filter: .overdue, now: now, calendar: calendar))
    }

    @Test func pinnedTasksSortBeforeUnpinnedWhileSearchAndFiltersApply() {
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 11, hour: 12))!
        let pinned = Task(title: "Important Work", dueDate: now, category: .work, isPinned: true)
        let regular = Task(title: "Important Personal", dueDate: now, category: .personal)
        let hidden = Task(title: "Other", dueDate: now, category: .study)

        let result = TaskRules.filteredAndSorted(
            tasks: [regular, hidden, pinned],
            searchText: "Important",
            filter: .today,
            now: now,
            calendar: calendar
        )

        #expect(result.map(\.id) == [pinned.id, regular.id])
    }

    @Test func recurrenceCreatesNextDailyWeeklyAndMonthlyOccurrences() {
        let date = calendar.date(from: DateComponents(year: 2026, month: 8, day: 11, hour: 9))!
        let daily = Task(title: "Daily", dueDate: date, recurrence: .daily)
        let weekly = Task(title: "Weekly", dueDate: date, recurrence: .weekly)
        let monthly = Task(title: "Monthly", dueDate: date, recurrence: .monthly)

        #expect(TaskRules.nextOccurrence(from: daily, calendar: calendar)?.dueDate == calendar.date(byAdding: .day, value: 1, to: date))
        #expect(TaskRules.nextOccurrence(from: weekly, calendar: calendar)?.dueDate == calendar.date(byAdding: .weekOfYear, value: 1, to: date))
        #expect(TaskRules.nextOccurrence(from: monthly, calendar: calendar)?.dueDate == calendar.date(byAdding: .month, value: 1, to: date))
    }

    @Test func recurrenceSkipsMissedOccurrencesWhenCompletingOverdueTask() {
        let dueDate = calendar.date(from: DateComponents(year: 2026, month: 8, day: 8, hour: 9))!
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 11, hour: 12))!
        let task = Task(title: "Daily", dueDate: dueDate, recurrence: .daily)

        let next = TaskRules.nextOccurrence(from: task, now: now, calendar: calendar)

        #expect(next?.dueDate == calendar.date(from: DateComponents(year: 2026, month: 8, day: 12, hour: 9)))
    }

    @Test func v2InMemoryContainerUsesMigrationPlanAndDefaultPersistedValues() throws {
        let schema = Schema(versionedSchema: TickTaskSchemaV2.self)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: schema,
            migrationPlan: TickTaskMigrationPlan.self,
            configurations: [configuration]
        )
        let context = ModelContext(container)
        let task = Task(title: "Migrated Shape")

        context.insert(task)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Task>())

        #expect(fetched.count == 1)
        #expect(fetched.first?.completedAt == nil)
        #expect(fetched.first?.isPinned == false)
        #expect(fetched.first?.recurrence == .never)
        #expect(fetched.first?.reminder == .none)
        #expect(fetched.first?.reminderDate == nil)
    }

    @Test func recurrenceDuplicateDetectionPreventsSameOpenOccurrence() {
        let date = calendar.date(from: DateComponents(year: 2026, month: 8, day: 11, hour: 9))!
        let existing = Task(title: "Standup", dueDate: date, category: .work, recurrence: .daily)
        let candidate = Task(title: "Standup", dueDate: date, category: .work, recurrence: .daily)

        #expect(TaskRules.hasEquivalentOccurrence(candidate, in: [existing], calendar: calendar))

        existing.isCompleted = true
        #expect(!TaskRules.hasEquivalentOccurrence(candidate, in: [existing], calendar: calendar))
    }

    @Test func statisticsCalculateCompletionRateAndStreaks() {
        let today = calendar.date(from: DateComponents(year: 2026, month: 8, day: 11, hour: 12))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: today)!

        let tasks = [
            Task(title: "Today", isCompleted: true, completedAt: today),
            Task(title: "Yesterday", isCompleted: true, completedAt: yesterday),
            Task(title: "Two Days Ago", isCompleted: true, completedAt: twoDaysAgo),
            Task(title: "Four Days Ago", isCompleted: true, completedAt: fourDaysAgo),
            Task(title: "Pending")
        ]

        let stats = TaskRules.statistics(tasks: tasks, now: today, calendar: calendar)
        #expect(stats.total == 5)
        #expect(stats.completed == 4)
        #expect(stats.pending == 1)
        #expect(stats.completionRate == 0.8)
        #expect(stats.currentStreak == 3)
        #expect(stats.longestStreak == 3)
    }

    @Test func dashboardSummaryCountsCompletedPendingTodayAndOverdue() {
        let now = calendar.date(from: DateComponents(year: 2026, month: 8, day: 11, hour: 12))!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let summary = TaskRules.dashboardSummary(
            tasks: [
                Task(title: "Done", dueDate: now, isCompleted: true, completedAt: now),
                Task(title: "Pending", dueDate: now),
                Task(title: "Late", dueDate: yesterday)
            ],
            now: now,
            calendar: calendar
        )

        #expect(summary.completed == 1)
        #expect(summary.pending == 2)
        #expect(summary.dueToday == 2)
        #expect(summary.overdue == 1)
    }

    @Test func appearanceAndSettingsPersistenceValuesRoundTrip() {
        UserDefaults.standard.set(AppearanceOption.dark.rawValue, forKey: "appearance")
        UserDefaults.standard.set(Priority.high.rawValue, forKey: "defaultPriority")
        UserDefaults.standard.set(Category.health.rawValue, forKey: "defaultCategory")
        Haptics.isEnabled = false

        #expect(AppearanceOption(rawValue: UserDefaults.standard.string(forKey: "appearance") ?? "") == .dark)
        #expect(Priority(rawValue: UserDefaults.standard.string(forKey: "defaultPriority") ?? "") == .high)
        #expect(Category(rawValue: UserDefaults.standard.string(forKey: "defaultCategory") ?? "") == .health)
        #expect(!Haptics.isEnabled)

        Haptics.isEnabled = true
    }
}
