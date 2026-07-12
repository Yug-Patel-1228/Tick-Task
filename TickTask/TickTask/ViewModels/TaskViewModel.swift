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

    var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
