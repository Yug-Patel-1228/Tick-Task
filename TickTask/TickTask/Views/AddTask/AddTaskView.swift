//
//  AddTaskView.swift
//  TickTask
//

import SwiftUI
import SwiftData

struct AddTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = TaskViewModel()
    @AppStorage("defaultPriority") private var defaultPriorityRawValue = Priority.medium.rawValue
    @AppStorage("defaultCategory") private var defaultCategoryRawValue = Category.personal.rawValue

    var body: some View {

        NavigationStack {

            Form {
                TaskFormFields(viewModel: viewModel)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(placement: .topBarLeading) {

                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {

                    Button("Save") {

                        let task = Task(
                            title: viewModel.cleanTitle,
                            notes: viewModel.notes,
                            dueDate: viewModel.hasDueDate ? viewModel.dueDate : nil,
                            priority: viewModel.priority,
                            category: viewModel.category,
                            color: viewModel.color,
                            recurrence: viewModel.recurrence,
                            reminder: viewModel.reminder,
                            reminderDate: viewModel.reminder == .specificDate ? viewModel.reminderDate : nil
                        )

                        modelContext.insert(task)
                        NotificationService.shared.scheduleNotification(for: task)
                        Haptics.success()

                        dismiss()
                    }
                    .disabled(viewModel.isSaveDisabled)
                    .accessibilityIdentifier("SaveTaskButton")
                }
            }
        }
        .onAppear {
            guard viewModel.title.isEmpty, viewModel.notes.isEmpty else { return }
            viewModel.priority = Priority(rawValue: defaultPriorityRawValue) ?? .medium
            viewModel.category = Category(rawValue: defaultCategoryRawValue) ?? .personal
        }
    }
}

#Preview {
    AddTaskView()
}
