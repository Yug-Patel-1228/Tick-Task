//
//  Category.swift
//  TickTask
//

import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {

    case personal = "Personal"
    case work = "Work"
    case study = "Study"
    case shopping = "Shopping"
    case health = "Health"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .personal:
            return "person.fill"
        case .work:
            return "briefcase.fill"
        case .study:
            return "book.fill"
        case .shopping:
            return "cart.fill"
        case .health:
            return "heart.fill"
        }
    }

    var color: Color {
        switch self {
        case .personal:
            return .blue
        case .work:
            return .indigo
        case .study:
            return .teal
        case .shopping:
            return .orange
        case .health:
            return .pink
        }
    }
}
