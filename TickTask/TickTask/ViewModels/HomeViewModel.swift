//
//  HomeViewModel.swift
//  TickTask
//

import Foundation

@Observable
final class HomeViewModel {

    var completedTasks: Int = 0
    var totalTasks: Int = 0

    var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
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
