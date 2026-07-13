import SwiftUI

struct EditTaskView: View {

    @Environment(\.dismiss) private var dismiss

    let task: Task
    @State private var viewModel: TaskViewModel

    init(task: Task) {
        self.task = task
        _viewModel = State(initialValue: TaskViewModel(task: task))
    }

    var body: some View {
        NavigationStack {
            Form {
                TaskFormFields(viewModel: viewModel)
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        task.title = viewModel.cleanTitle
                        task.notes = viewModel.notes
                        task.dueDate = viewModel.hasDueDate ? viewModel.dueDate : nil
                        task.priority = viewModel.priority
                        task.category = viewModel.category
                        task.color = viewModel.color
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
    EditTaskView(task: Task(title: "Study SwiftUI", dueDate: .now))
}
