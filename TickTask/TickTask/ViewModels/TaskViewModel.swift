//
//  TaskViewModel.swift
//  TickTask
//
//  Created by Yug on 7/12/26.
//

import Foundation
import Observation

@Observable
final class TaskViewModel {

    var title = ""
    var notes = ""

    var hasDueDate = false
    var dueDate = Date()

    var priority: Priority = .medium
    var category: Category = .personal
    var color: TaskColor = .blue
    var recurrence: RecurrenceRule = .never
    var reminder: ReminderKind = .none
    var reminderDate = Date()

    var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(
        task: Task? = nil,
        defaultPriority: Priority = .medium,
        defaultCategory: Category = .personal
    ) {
        priority = defaultPriority
        category = defaultCategory

        guard let task else { return }

        title = task.title
        notes = task.notes
        hasDueDate = task.dueDate != nil
        dueDate = task.dueDate ?? Date()
        priority = task.priority
        category = task.category
        color = task.color
        recurrence = task.recurrence
        reminder = task.reminder
        reminderDate = task.reminderDate ?? task.dueDate ?? Date()
    }

    var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
