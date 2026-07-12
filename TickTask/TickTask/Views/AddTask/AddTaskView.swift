//
//  AddTaskView.swift
//  TickTask
//
//  Created by Yug on 7/12/26.
//

import SwiftUI

struct AddTaskView: View {

    @Environment(\.dismiss) private var dismiss

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

                        ForEach(Priority.allCases, id: \.self) {

                            Text($0.rawValue)

                        }
                    }
                }

                Section("Category") {

                    Picker("Category", selection: $viewModel.category) {

                        ForEach(Category.allCases, id: \.self) {

                            Text($0.rawValue)

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

                        dismiss()

                    }
                    .disabled(viewModel.isSaveDisabled)                }
            }
        }
    }
}

#Preview {
    AddTaskView()
}
