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

    var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(task: Task? = nil) {
        guard let task else { return }

        title = task.title
        notes = task.notes
        hasDueDate = task.dueDate != nil
        dueDate = task.dueDate ?? Date()
        priority = task.priority
        category = task.category
        color = task.color
    }

    var cleanTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
