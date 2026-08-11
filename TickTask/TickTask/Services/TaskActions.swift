import Foundation
import SwiftData
import SwiftUI

enum TaskActions {
    static func toggleComplete(
        _ task: Task,
        allTasks: [Task],
        modelContext: ModelContext,
        animation: Animation?
    ) {
        withAnimation(animation) {
            if task.isCompleted {
                task.isCompleted = false
                task.completedAt = nil
                NotificationService.shared.scheduleNotification(for: task)
            } else {
                task.isCompleted = true
                task.completedAt = Date()
                NotificationService.shared.cancelNotification(for: task)

                if let next = TaskRules.nextOccurrence(from: task),
                   !TaskRules.hasEquivalentOccurrence(next, in: allTasks) {
                    modelContext.insert(next)
                    NotificationService.shared.scheduleNotification(for: next)
                }
            }
        }

        Haptics.selection()
    }

    static func delete(_ task: Task, modelContext: ModelContext, animation: Animation?) {
        NotificationService.shared.cancelNotification(for: task)

        withAnimation(animation) {
            modelContext.delete(task)
        }

        Haptics.warning()
    }

    static func duplicate(_ task: Task, modelContext: ModelContext, animation: Animation?) {
        let duplicate = TaskRules.duplicate(of: task)

        withAnimation(animation) {
            modelContext.insert(duplicate)
        }

        NotificationService.shared.scheduleNotification(for: duplicate)
        Haptics.success()
    }

    static func togglePin(_ task: Task, animation: Animation?) {
        withAnimation(animation) {
            task.isPinned.toggle()
        }

        Haptics.selection()
    }
}
