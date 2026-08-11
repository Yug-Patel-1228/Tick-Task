import SwiftUI
import SwiftData

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let task: Task
    @Query private var allTasks: [Task]
    @State private var editingTask: Task?
    @State private var showingDeleteConfirmation = false

    private var taskAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.01) : .spring(response: 0.28, dampingFraction: 0.82)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    HStack(spacing: AppSpacing.small) {
                        if task.isPinned {
                            Image(systemName: AppSymbols.pin)
                                .foregroundStyle(AppColors.accent)
                        }

                        Text(task.title)
                            .font(AppTypography.largeTitle)
                            .foregroundStyle(AppColors.textPrimary)
                            .lineLimit(nil)
                    }

                    Label(task.category.rawValue, systemImage: task.category.symbol)
                        .foregroundStyle(task.category.color)
                        .font(AppTypography.subheadline)
                }

                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    detailRow("Priority", value: task.priority.rawValue, symbol: AppSymbols.flag, color: task.priority.color)
                    detailRow("Due Date", value: task.dueDate?.formatted(date: .abbreviated, time: .shortened) ?? "No due date", symbol: AppSymbols.calendar)
                    detailRow("Created", value: task.createdAt.formatted(date: .abbreviated, time: .omitted), symbol: "clock")
                    detailRow("Repeats", value: task.recurrence.rawValue, symbol: AppSymbols.recurrence)
                    detailRow("Reminder", value: task.reminder.rawValue, symbol: AppSymbols.bell)
                }
                .padding(AppSpacing.cardPadding)
                .background(AppColors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Notes")
                        .font(AppTypography.headline)

                    Text(task.notes.isEmpty ? "No notes" : task.notes)
                        .font(AppTypography.body)
                        .foregroundStyle(task.notes.isEmpty ? AppColors.textSecondary : AppColors.textPrimary)
                        .textSelection(.enabled)
                }

                HStack(spacing: AppSpacing.medium) {
                    Button {
                        toggleComplete()
                    } label: {
                        Label(task.isCompleted ? "Completed" : "Complete", systemImage: task.isCompleted ? AppSymbols.completed : AppSymbols.incomplete)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        togglePin()
                    } label: {
                        Label(task.isPinned ? "Unpin" : "Pin", systemImage: task.isPinned ? AppSymbols.unpin : AppSymbols.pin)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .controlSize(.large)
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    editingTask = task
                }
            }

            ToolbarItem(placement: .bottomBar) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: AppSymbols.delete)
                }
            }
        }
        .sheet(item: $editingTask) { task in
            EditTaskView(task: task)
        }
        .alert("Delete Task?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteTask()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the task from this device.")
        }
    }

    private func detailRow(_ label: String, value: String, symbol: String, color: Color = AppColors.textSecondary) -> some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: symbol)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(label)
                .foregroundStyle(AppColors.textSecondary)

            Spacer(minLength: AppSpacing.medium)

            Text(value)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.trailing)
        }
        .font(AppTypography.body)
    }

    private func toggleComplete() {
        TaskActions.toggleComplete(
            task,
            allTasks: allTasks,
            modelContext: modelContext,
            animation: taskAnimation
        )
    }

    private func togglePin() {
        TaskActions.togglePin(
            task,
            animation: reduceMotion ? .easeInOut(duration: 0.01) : .spring(response: 0.25, dampingFraction: 0.88)
        )
    }

    private func deleteTask() {
        TaskActions.delete(task, modelContext: modelContext, animation: taskAnimation)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        TaskDetailView(task: Task(title: "Write V2 notes", notes: "Review details", dueDate: .now))
    }
}
