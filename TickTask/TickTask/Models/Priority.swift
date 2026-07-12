//
//  Priority.swift
//  TickTask
//

import SwiftUI

enum Priority: String, Codable, CaseIterable {

    case low = "Low"
    case medium = "Medium"
    case high = "High"

    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}
