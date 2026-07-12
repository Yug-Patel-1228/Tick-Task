//
//  TaskRow.swift
//  TickTask
//

import SwiftUI

struct TaskRow: View {

    let task: Task

    var body: some View {

        HStack(alignment: .top, spacing: AppSpacing.medium) {

            Image(systemName: task.isCompleted ? AppSymbols.completed : AppSymbols.incomplete)
                .font(.title3)
                .foregroundStyle(task.isCompleted ? AppColors.success : AppColors.textSecondary)

            VStack(alignment: .leading, spacing: 6) {

                Text(task.title)
                    .font(AppTypography.headline)
                    .strikethrough(task.isCompleted)

                HStack(spacing: 8) {

                    Text(task.category.rawValue)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)

                    if let dueDate = task.dueDate {

                        Text("•")

                        Text(dueDate, style: .date)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }

            Spacer()

            Circle()
                .fill(task.priority.color)
                .frame(width: 10, height: 10)
        }
        .padding(AppSpacing.medium)
        .background(AppColors.card)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppSpacing.cornerRadius,
                style: .continuous
            )
        )
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
        )
    )
    .padding()
}
