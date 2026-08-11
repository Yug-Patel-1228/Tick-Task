//
//  TaskRow.swift
//  TickTask
//

import SwiftUI

struct TaskRow: View {

    let task: Task
    let onToggleComplete: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    let onPin: () -> Void

    var body: some View {

        HStack(alignment: .top, spacing: AppSpacing.medium) {

            Button(action: onToggleComplete) {
                Image(systemName: task.isCompleted ? AppSymbols.completed : AppSymbols.incomplete)
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? AppColors.success : AppColors.textSecondary)
                    .contentTransition(.symbolEffect(.replace))
                    .scaleEffect(task.isCompleted ? 1.08 : 1)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isCompleted ? "Mark \(task.title) incomplete" : "Complete \(task.title)")

            VStack(alignment: .leading, spacing: 6) {

                HStack(spacing: 6) {
                    if task.isPinned {
                        Image(systemName: AppSymbols.pin)
                            .font(.caption)
                            .foregroundStyle(AppColors.accent)
                            .accessibilityLabel("Pinned")
                    }

                    Text(task.title)
                        .font(AppTypography.headline)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                        .lineLimit(2)
                }

                HStack(spacing: 8) {

                    Label(task.category.rawValue, systemImage: task.category.symbol)
                        .font(AppTypography.caption)
                        .foregroundStyle(task.category.color)

                    if let dueDate = task.dueDate {

                        Text("•")
                            .foregroundStyle(AppColors.textSecondary)

                        Text(dueDate, style: .date)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Text("•")
                        .foregroundStyle(AppColors.textSecondary)

                    Text(task.priority.rawValue)
                        .font(AppTypography.caption)
                        .foregroundStyle(task.priority.color)

                    if task.recurrence != .never {
                        Text("•")
                            .foregroundStyle(AppColors.textSecondary)

                        Label(task.recurrence.rawValue, systemImage: AppSymbols.recurrence)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            }

            Spacer()

            Circle()
                .fill(task.color.color)
                .frame(width: 12, height: 12)
        }
        .padding(AppSpacing.medium)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppSpacing.cornerRadius,
                style: .continuous
            )
        )
        .opacity(task.isCompleted ? 0.72 : 1)
        .contextMenu {
            Button(action: onToggleComplete) {
                Label(task.isCompleted ? "Mark Incomplete" : "Complete", systemImage: task.isCompleted ? AppSymbols.incomplete : AppSymbols.completed)
            }

            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }

            Button(action: onDuplicate) {
                Label("Duplicate", systemImage: AppSymbols.duplicate)
            }

            Button(action: onPin) {
                Label(task.isPinned ? "Unpin" : "Pin", systemImage: task.isPinned ? AppSymbols.unpin : AppSymbols.pin)
            }

            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: AppSymbols.delete)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(task.title), \(task.category.rawValue), \(task.priority.rawValue)")
    }
}

#Preview {

    TaskRow(
        task: Task(
            title: "Buy Groceries",
            notes: "Milk, Eggs, Bread",
            dueDate: .now,
            priority: .high,
            category: .shopping
        ),
        onToggleComplete: {},
        onEdit: {},
        onDelete: {},
        onDuplicate: {},
        onPin: {}
    )
    .padding()
}
