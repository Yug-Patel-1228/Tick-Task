import SwiftUI

struct TaskFormFields: View {

    @Bindable var viewModel: TaskViewModel

    var body: some View {
        Section("Task") {
            TextField("Title", text: $viewModel.title)
                .textInputAutocapitalization(.sentences)

            TextField("Notes", text: $viewModel.notes, axis: .vertical)
                .lineLimit(3...6)
        }

        Section("Due Date") {
            Toggle("Set Due Date", isOn: $viewModel.hasDueDate.animation())

            if viewModel.hasDueDate {
                DatePicker(
                    "Due Date",
                    selection: $viewModel.dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        }

        Section("Priority") {
            Picker("Priority", selection: $viewModel.priority) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    Label(priority.rawValue, systemImage: AppSymbols.flag)
                        .tint(priority.color)
                        .tag(priority)
                }
            }
            .pickerStyle(.segmented)
        }

        Section("Category") {
            Picker("Category", selection: $viewModel.category) {
                ForEach(Category.allCases, id: \.self) { category in
                    Label(category.rawValue, systemImage: category.symbol)
                        .tint(category.color)
                        .tag(category)
                }
            }
        }

        Section("Recurrence") {
            Picker("Repeats", selection: $viewModel.recurrence) {
                ForEach(RecurrenceRule.allCases, id: \.self) { recurrence in
                    Label(
                        recurrence.rawValue,
                        systemImage: AppSymbols.recurrence
                    )
                    .tag(recurrence)
                }
            }
        }

        Section("Reminder") {
            Picker("Reminder", selection: $viewModel.reminder) {
                ForEach(ReminderKind.allCases, id: \.self) { reminder in
                    Label(
                        reminder.rawValue,
                        systemImage: AppSymbols.bell
                    )
                    .tag(reminder)
                }
            }

            if viewModel.reminder == .specificDate {
                DatePicker(
                    "Reminder Date",
                    selection: $viewModel.reminderDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        }

        Section("Color") {
            Picker("Color", selection: $viewModel.color) {
                ForEach(TaskColor.allCases, id: \.self) { color in
                    Label(
                        color.rawValue,
                        systemImage: "circle.fill"
                    )
                    .tint(color.color)
                    .tag(color)
                }
            }
        }
    }
}

#Preview {
    Form {
        TaskFormFields(viewModel: TaskViewModel())
    }
}
