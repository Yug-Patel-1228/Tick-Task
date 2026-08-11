import SwiftUI
import SwiftData

struct HomeView: View {

    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask = false
    @State private var editingTask: Task?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @Query(sort: \Task.createdAt, order: .reverse)
    private var tasks: [Task]

    private var filteredTasks: [Task] {
        viewModel.visibleTasks(from: tasks, searchText: searchText, filter: selectedFilter)
    }

    private var dashboardSummary: DashboardSummary {
        viewModel.dashboardSummary(from: tasks)
    }

    private var taskAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.01) : .spring(response: 0.3, dampingFraction: 0.86)
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
                            completedTasks: dashboardSummary.completed,
                            totalTasks: tasks.count,
                            pendingTasks: dashboardSummary.pending,
                            dueTodayTasks: dashboardSummary.dueToday,
                            overdueTasks: dashboardSummary.overdue
                        )

                        SearchBar(text: $searchText)
                            .accessibilityIdentifier("TaskSearchField")

                        filterPicker

                        if filteredTasks.isEmpty {

                            EmptyState(
                                title: searchText.isEmpty ? "No Tasks" : "No Results",
                                message: searchText.isEmpty
                                ? "Create a task to start planning your day."
                                : "Try a different search or filter.",
                                buttonTitle: "Create Task",
                                action: {
                                    showingAddTask = true
                                }
                            )

                        } else {

                            LazyVStack(spacing: AppSpacing.medium) {

                                ForEach(filteredTasks) { task in
                                    NavigationLink {
                                        TaskDetailView(task: task)
                                    } label: {
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
                                            },
                                            onPin: {
                                                togglePin(task)
                                            }
                                        )
                                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button {
                                                toggleComplete(task)
                                            } label: {
                                                Label(task.isCompleted ? "Undo" : "Complete", systemImage: task.isCompleted ? AppSymbols.incomplete : AppSymbols.completed)
                                            }
                                            .tint(AppColors.success)

                                            Button {
                                                togglePin(task)
                                            } label: {
                                                Label(task.isPinned ? "Unpin" : "Pin", systemImage: task.isPinned ? AppSymbols.unpin : AppSymbols.pin)
                                            }
                                            .tint(AppColors.accent)
                                        }
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button {
                                                editingTask = task
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(AppColors.warning)

                                            Button(role: .destructive) {
                                                delete(task)
                                            } label: {
                                                Label("Delete", systemImage: AppSymbols.delete)
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)

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
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        StatisticsView()
                    } label: {
                        Image(systemName: AppSymbols.statistics)
                    }
                    .accessibilityLabel("Statistics")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: AppSymbols.settings)
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showingAddTask) {

                AddTaskView()

            }
            .sheet(item: $editingTask) { task in
                EditTaskView(task: task)
            }
            .animation(reduceMotion ? .easeInOut(duration: 0.01) : .spring(response: 0.3, dampingFraction: 0.86), value: filteredTasks.map(\.id))
            .animation(reduceMotion ? .easeInOut(duration: 0.01) : .easeInOut(duration: 0.2), value: selectedFilter)
        }
    }

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.small) {
                ForEach(TaskFilter.allCases) { filter in
                    Button {
                        selectedFilter = filter
                        Haptics.selection()
                    } label: {
                        Text(filter.rawValue)
                            .font(AppTypography.subheadline)
                            .fontWeight(selectedFilter == filter ? .semibold : .regular)
                            .padding(.horizontal, 14)
                            .frame(height: 36)
                            .background(selectedFilter == filter ? AppColors.accent : AppColors.secondaryBackground)
                            .foregroundStyle(selectedFilter == filter ? .white : AppColors.textPrimary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(filter.rawValue) filter")
                    .accessibilityIdentifier("Filter\(filter.rawValue)")
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func toggleComplete(_ task: Task) {
        TaskActions.toggleComplete(
            task,
            allTasks: tasks,
            modelContext: modelContext,
            animation: reduceMotion ? .easeInOut(duration: 0.01) : .spring(response: 0.28, dampingFraction: 0.82)
        )
    }

    private func delete(_ task: Task) {
        TaskActions.delete(task, modelContext: modelContext, animation: taskAnimation)
    }

    private func duplicate(_ task: Task) {
        TaskActions.duplicate(task, modelContext: modelContext, animation: taskAnimation)
    }

    private func togglePin(_ task: Task) {
        TaskActions.togglePin(
            task,
            animation: reduceMotion ? .easeInOut(duration: 0.01) : .spring(response: 0.25, dampingFraction: 0.88)
        )
    }
}

#Preview {
    HomeView()
}
