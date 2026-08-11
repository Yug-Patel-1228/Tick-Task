//
//  ProgressCard.swift
//  TickTask
//
//  Created by Yug on 12/07/26.
//

import SwiftUI

struct ProgressCard: View {

    let completedTasks: Int
    let totalTasks: Int
    let pendingTasks: Int
    let dueTodayTasks: Int
    let overdueTasks: Int

    private var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }

    var body: some View {

        VStack(alignment: .leading, spacing: AppSpacing.medium) {

            HStack {
                Text("Today's Progress")
                    .font(AppTypography.title2)

                Spacer()

                Text("\(completedTasks) / \(totalTasks)")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.accent)
            }

            Text("\(completedTasks) of \(totalTasks) tasks completed")
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            ProgressView(value: progress)
                .tint(AppColors.accent)
                .animation(.easeInOut(duration: 0.28), value: progress)

            HStack(spacing: AppSpacing.small) {
                metric("Done", completedTasks, AppColors.success)
                metric("Pending", pendingTasks, AppColors.warning)
                metric("Today", dueTodayTasks, AppColors.accent)
                metric("Overdue", overdueTasks, AppColors.danger)
            }
            .padding(.top, AppSpacing.small)
        }
        .padding(AppSpacing.cardPadding)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppSpacing.cornerRadius,
                style: .continuous
            )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(completedTasks) completed, \(pendingTasks) pending, \(dueTodayTasks) due today, \(overdueTasks) overdue")
    }

    private func metric(_ title: String, _ value: Int, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text("\(value)")
                .font(AppTypography.headline)
                .foregroundStyle(color)

            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProgressCard(
        completedTasks: 3,
        totalTasks: 8,
        pendingTasks: 5,
        dueTodayTasks: 2,
        overdueTasks: 1
    )
    .padding()
}
