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

            VStack(alignment: .leading, spacing: 6) {

                Text(task.title)
                    .font(AppTypography.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)

                HStack(spacing: 8) {

                    Text(task.category.rawValue)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)

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
                }
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
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }

            Button(action: onDuplicate) {
                Label("Duplicate", systemImage: AppSymbols.duplicate)
            }

            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: AppSymbols.delete)
            }
        }
        .onTapGesture(count: 2, perform: onEdit)
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
        onDuplicate: {}
    )
    .padding()
}
