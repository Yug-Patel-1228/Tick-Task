import Foundation

enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case today = "Today"
    case upcoming = "Upcoming"
    case completed = "Completed"
    case overdue = "Overdue"

    var id: String { rawValue }
}
