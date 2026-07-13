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
                            color: viewModel.color
                        )

                        modelContext.insert(task)
                        Haptics.success()

                        dismiss()
                    }
                    .disabled(viewModel.isSaveDisabled)
                }
            }
        }
    }
}

#Preview {
    AddTaskView()
}
