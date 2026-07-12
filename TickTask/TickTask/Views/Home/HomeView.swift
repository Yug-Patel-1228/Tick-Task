import SwiftUI

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var showingAddTask = false

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottomTrailing) {

                ScrollView {

                    VStack(alignment: .leading,
                           spacing: AppSpacing.large) {

                        Text(viewModel.greeting)
                            .font(AppTypography.title)

                        ProgressCard(
                            completedTasks: viewModel.completedTasks,
                            totalTasks: viewModel.totalTasks
                        )

                        SearchBar(text: $searchText)

                        EmptyState()
                    }
                    .padding()
                }

                FloatingButton {
                    showingAddTask=true

                }
                .padding(24)
            }
            .navigationTitle("Today")
            .sheet(isPresented: $showingAddTask) {

                AddTaskView()

            }
        }
    }
}

#Preview {
    HomeView()
}
