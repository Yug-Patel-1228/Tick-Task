//
//  Category.swift
//  TickTask
//

import Foundation

enum Category: String, Codable, CaseIterable {

    case personal = "Personal"
    case work = "Work"
    case study = "Study"
    case shopping = "Shopping"
    case health = "Health"
}
