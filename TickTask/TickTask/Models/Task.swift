//
//  Task.swift
//  TickTask
//
//  Created by Yug on 12/07/26.
//

import Foundation
import SwiftData

@Model
final class Task: Identifiable {

    var id: UUID
    var title: String
    var notes: String

    var createdAt: Date
    var dueDate: Date?

    var priority: Priority
    var category: Category
    var color: TaskColor

    var isCompleted: Bool

    init(
        title: String,
        notes: String = "",
        dueDate: Date? = nil,
        priority: Priority = .medium,
        category: Category = .personal,
        color: TaskColor = .blue,
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.createdAt = Date()
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        self.color = color
        self.isCompleted = isCompleted
    }
}
