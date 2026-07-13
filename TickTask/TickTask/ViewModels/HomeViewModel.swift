//
//  HomeViewModel.swift
//  TickTask
//

import Foundation

@Observable
final class HomeViewModel {

    func completedTasks(from tasks: [Task]) -> Int {
        tasks.filter(\.isCompleted).count
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
