//
//  Task.swift
//  TickTask
//
//  Created by Yug on 12/07/26.
//

import Foundation
import SwiftData

// MARK: - Version 1
//
// This schema is FROZEN.
// Do not modify it after it has been used on a device.

enum TickTaskSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Task.self]
    }

    @Model
    final class Task: Identifiable {
        var id: UUID
        var title: String
        var notes: String

        var createdAt: Date
        var dueDate: Date?

        var priority: Priority
        var category: Category
        var color: TaskColor

        var isCompleted: Bool

        init(
            title: String,
            notes: String = "",
            dueDate: Date? = nil,
            priority: Priority = .medium,
            category: Category = .personal,
            color: TaskColor = .blue,
            isCompleted: Bool = false
        ) {
            self.id = UUID()
            self.title = title
            self.notes = notes
            self.createdAt = Date()
            self.dueDate = dueDate
            self.priority = priority
            self.category = category
            self.color = color
            self.isCompleted = isCompleted
        }
    }
}


// MARK: - Version 2
//
// IMPORTANT:
// This is a historical snapshot of the currently shipped/broken V2
// schema on the device.
//
// DO NOT MODIFY THIS SCHEMA.
//
// SwiftData needs this exact schema to recognize the existing V2 store.

enum TickTaskSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Task.self]
    }

    @Model
    final class Task: Identifiable {
        var id: UUID
        var title: String
        var notes: String

        var createdAt: Date
        var dueDate: Date?
        var completedAt: Date?

        var priority: Priority
        var category: Category
        var color: TaskColor

        var isCompleted: Bool
        var isPinned: Bool
        var recurrence: RecurrenceRule
        var reminder: ReminderKind
        var reminderDate: Date?

        init(
            title: String,
            notes: String = "",
            dueDate: Date? = nil,
            priority: Priority = .medium,
            category: Category = .personal,
            color: TaskColor = .blue,
            isCompleted: Bool = false,
            completedAt: Date? = nil,
            isPinned: Bool = false,
            recurrence: RecurrenceRule = .never,
            reminder: ReminderKind = .none,
            reminderDate: Date? = nil
        ) {
            self.id = UUID()
            self.title = title
            self.notes = notes
            self.createdAt = Date()
            self.dueDate = dueDate
            self.completedAt = completedAt
            self.priority = priority
            self.category = category
            self.color = color
            self.isCompleted = isCompleted
            self.isPinned = isPinned
            self.recurrence = recurrence
            self.reminder = reminder
            self.reminderDate = reminderDate
        }
    }
}


// MARK: - Version 3
//
// V3 fixes the migration problem.
//
// New V2 enum properties are NOT persisted directly as non-optional enums.
//
// Instead:
//
//     recurrenceRawValue: String?
//     reminderRawValue: String?
//
// are persisted.
//
// The public application API remains:
//
//     task.recurrence
//     task.reminder
//
// through computed properties.
//
// This prevents SwiftData from trying to cast an old nil payload into
// a non-optional enum.

enum TickTaskSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Task.self]
    }

    @Model
    final class Task: Identifiable {

        // MARK: Core V1 properties

        var id: UUID
        var title: String
        var notes: String

        var createdAt: Date
        var dueDate: Date?

        var priority: Priority
        var category: Category
        var color: TaskColor

        var isCompleted: Bool


        // MARK: V2 properties

        var completedAt: Date?


        // IMPORTANT:
        // Persist this as optional because the existing V2 store may contain
        // no value for this field.
        //
        // originalName preserves the existing V2 attribute name.
        @Attribute(originalName: "isPinned")
        var isPinnedStorage: Bool?


        // MARK: Safe V3 persistence for recurrence

        //
        // These are intentionally optional primitive values.
        //
        // Existing V2 rows may not contain a recurrence value at all.
        // Optional String safely represents that state.
        //
        var recurrenceRawValue: String?


        // MARK: Safe V3 persistence for reminders

        var reminderRawValue: String?

        var reminderDate: Date?


        // MARK: Public application API

        //
        // The rest of TickTask continues to use:
        //
        //     task.isPinned
        //     task.recurrence
        //     task.reminder
        //
        // without knowing how those values are persisted.

        var isPinned: Bool {
            get {
                isPinnedStorage ?? false
            }
            set {
                isPinnedStorage = newValue
            }
        }

        var recurrence: RecurrenceRule {
            get {
                guard let rawValue = recurrenceRawValue,
                      let value = RecurrenceRule(rawValue: rawValue)
                else {
                    return .never
                }

                return value
            }
            set {
                recurrenceRawValue = newValue.rawValue
            }
        }

        var reminder: ReminderKind {
            get {
                guard let rawValue = reminderRawValue,
                      let value = ReminderKind(rawValue: rawValue)
                else {
                    return .none
                }

                return value
            }
            set {
                reminderRawValue = newValue.rawValue
            }
        }


        // MARK: Initialization

        init(
            title: String,
            notes: String = "",
            dueDate: Date? = nil,
            priority: Priority = .medium,
            category: Category = .personal,
            color: TaskColor = .blue,
            isCompleted: Bool = false,
            completedAt: Date? = nil,
            isPinned: Bool = false,
            recurrence: RecurrenceRule = .never,
            reminder: ReminderKind = .none,
            reminderDate: Date? = nil
        ) {
            self.id = UUID()
            self.title = title
            self.notes = notes
            self.createdAt = Date()
            self.dueDate = dueDate

            self.priority = priority
            self.category = category
            self.color = color

            self.isCompleted = isCompleted
            self.completedAt = completedAt

            self.isPinnedStorage = isPinned

            self.recurrenceRawValue = recurrence.rawValue
            self.reminderRawValue = reminder.rawValue
            self.reminderDate = reminderDate
        }
    }
}


// MARK: - Current Task API
//
// All existing application code continues to use:
//
//     Task
//
// so the rest of the MVVM/SwiftUI architecture does not need to change.

typealias Task = TickTaskSchemaV3.Task


// MARK: - Migration Plan

enum TickTaskMigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        [
            TickTaskSchemaV1.self,
            TickTaskSchemaV2.self,
            TickTaskSchemaV3.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            migrateV1toV2,
            migrateV2toV3
        ]
    }


    // MARK: V1 → V2

    //
    // V2 introduced several required properties.
    //
    // The original implementation used lightweight migration, but that
    // allowed the newly-added enum fields to remain nil in existing rows.
    //
    // Use a custom migration so existing V1 rows receive explicit values.
    //

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: TickTaskSchemaV1.self,
        toVersion: TickTaskSchemaV2.self,
        willMigrate: nil,
        didMigrate: { context in

            let tasks = try context.fetch(
                FetchDescriptor<TickTaskSchemaV2.Task>()
            )

            for task in tasks {
                task.completedAt = nil
                task.isPinned = false

                // Explicitly initialize the new enum-backed properties.
                task.recurrence = .never
                task.reminder = .none
                task.reminderDate = nil
            }

            try context.save()
        }
    )


    // MARK: V2 → V3

    //
    // V2 is the problematic schema currently installed on the device.
    //
    // IMPORTANT:
    //
    // Do NOT access:
    //
    //     task.recurrence
    //     task.reminder
    //
    // during this migration.
    //
    // Those are precisely the getters that can crash when the old V2
    // persistent value is nil.
    //
    // V3 uses optional primitive storage instead.
    //

    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: TickTaskSchemaV2.self,
        toVersion: TickTaskSchemaV3.self
    )
}
