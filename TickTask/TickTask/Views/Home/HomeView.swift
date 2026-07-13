import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var showingAddTask = false
    @State private var editingTask: Task?
    
    @Query(sort: \Task.createdAt, order: .reverse)
    private var tasks: [Task]

    private var filteredTasks: [Task] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return tasks
        }

        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText) ||
            task.notes.localizedCaseInsensitiveContains(searchText) ||
            task.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var completedToday: Int {
        viewModel.completedTasks(from: filteredTasks)
    }

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottomTrailing) {

                ScrollView {

                    VStack(alignment: .leading,
                           spacing: AppSpacing.large) {

                        Text(viewModel.greeting)
                            .font(AppTypography.title)

                        ProgressCard(
                            completedTasks: completedToday,
                            totalTasks: filteredTasks.count
                        )

                        SearchBar(text: $searchText)

                        if filteredTasks.isEmpty {

                            EmptyState(
                                title: searchText.isEmpty ? "No Tasks" : "No Results",
                                message: searchText.isEmpty
                                ? "Tap + to add your first task"
                                : "Try a different search"
                            )

                        } else {

                            LazyVStack(spacing: AppSpacing.medium) {

                                ForEach(filteredTasks) { task in

                                    TaskRow(
                                        task: task,
                                        onToggleComplete: {
                                            toggleComplete(task)
                                        },
                                        onEdit: {
                                            editingTask = task
                                        },
                                        onDelete: {
                                            delete(task)
                                        },
                                        onDuplicate: {
                                            duplicate(task)
                                        }
                                    )
                                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        Button {
                                            toggleComplete(task)
                                        } label: {
                                            Label("Complete", systemImage: AppSymbols.completed)
                                        }
                                        .tint(AppColors.success)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            delete(task)
                                        } label: {
                                            Label("Delete", systemImage: AppSymbols.delete)
                                        }
                                    }

                                }
                            }
                        }
                    }
                    .padding()
                }

                FloatingButton {
                    showingAddTask = true
                    Haptics.selection()
                }
                .padding(24)
            }
            .background(AppColors.background)
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: AppSymbols.settings)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {

                AddTaskView()

            }
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task)
            }
        }
    }

    private func toggleComplete(_ task: Task) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            task.isCompleted.toggle()
        }
        Haptics.selection()
    }

    private func delete(_ task: Task) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            modelContext.delete(task)
        }
        Haptics.warning()
    }

    private func duplicate(_ task: Task) {
        let duplicate = Task(
            title: task.title,
            notes: task.notes,
            dueDate: task.dueDate,
            priority: task.priority,
            category: task.category,
            color: task.color,
            isCompleted: false
        )

        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            modelContext.insert(duplicate)
        }
        Haptics.success()
    }
}

#Preview {
    HomeView()
}
