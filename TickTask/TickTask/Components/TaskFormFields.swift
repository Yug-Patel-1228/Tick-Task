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
                    displayedComponents: .date
                )
            }
        }

        Section("Priority") {
            Picker("Priority", selection: $viewModel.priority) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    Label(priority.rawValue, systemImage: AppSymbols.flag)
                        .tint(priority.color)
                }
            }
            .pickerStyle(.segmented)
        }

        Section("Category") {
            Picker("Category", selection: $viewModel.category) {
                ForEach(Category.allCases, id: \.self) { category in
                    Text(category.rawValue)
                }
            }
        }

        Section("Color") {
            Picker("Color", selection: $viewModel.color) {
                ForEach(TaskColor.allCases, id: \.self) { color in
                    Label(color.rawValue, systemImage: "circle.fill")
                        .tint(color.color)
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
