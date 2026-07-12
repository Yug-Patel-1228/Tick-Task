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

                Section("Task") {

                    TextField("Title", text: $viewModel.title)

                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                }

                Section("Due Date") {

                    Toggle("Set Due Date", isOn: $viewModel.hasDueDate)

                    if viewModel.hasDueDate {

                        DatePicker(
                            "Due Date",
                            selection: $viewModel.dueDate,
                            displayedComponents: .date
                        )
                    }
                }

                Section("Priority") {

                    Picker("Priority", selection: $viewModel.priority) {

                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue)
                        }
                    }
                }

                Section("Category") {

                    Picker("Category", selection: $viewModel.category) {

                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                }
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
                            title: viewModel.title,
                            notes: viewModel.notes,
                            dueDate: viewModel.hasDueDate ? viewModel.dueDate : nil,
                            priority: viewModel.priority,
                            category: viewModel.category
                        )

                        modelContext.insert(task)

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
