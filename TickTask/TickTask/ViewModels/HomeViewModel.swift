//
//  HomeViewModel.swift
//  TickTask
//

import Foundation

@Observable
final class HomeViewModel {

    func visibleTasks(from tasks: [Task], searchText: String, filter: TaskFilter) -> [Task] {
        TaskRules.filteredAndSorted(tasks: tasks, searchText: searchText, filter: filter)
    }

    func dashboardSummary(from tasks: [Task]) -> DashboardSummary {
        TaskRules.dashboardSummary(tasks: tasks)
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            return "Good Morning"

        case 12..<17:
            return "Good Afternoon"

        default:
            return "Good Evening"
        }
    }
}
