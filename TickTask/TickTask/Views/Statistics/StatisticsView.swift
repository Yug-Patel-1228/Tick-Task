import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var tasks: [Task]

    private var statistics: TaskStatistics {
        TaskRules.statistics(tasks: tasks)
    }

    var body: some View {
        List {
            Section {
                statRow("Total Tasks", value: "\(statistics.total)", symbol: "list.bullet")
                statRow("Completed", value: "\(statistics.completed)", symbol: AppSymbols.completed, color: AppColors.success)
                statRow("Pending", value: "\(statistics.pending)", symbol: AppSymbols.incomplete, color: AppColors.warning)
                statRow("Completion Rate", value: statistics.completionRate.formatted(.percent.precision(.fractionLength(0))), symbol: "percent")
            }

            Section("Streaks") {
                statRow("Current Streak", value: "\(statistics.currentStreak) days", symbol: "flame.fill", color: .orange)
                statRow("Longest Streak", value: "\(statistics.longestStreak) days", symbol: "trophy.fill", color: .yellow)
            }
        }
        .navigationTitle("Statistics")
    }

    private func statRow(_ title: String, value: String, symbol: String, color: Color = AppColors.accent) -> some View {
        LabeledContent {
            Text(value)
                .font(AppTypography.headline)
        } label: {
            Label(title, systemImage: symbol)
                .foregroundStyle(color)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}

#Preview {
    NavigationStack {
        StatisticsView()
    }
}
