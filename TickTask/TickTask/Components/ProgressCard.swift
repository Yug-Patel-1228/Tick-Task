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

    private var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }

    var body: some View {

        VStack(alignment: .leading, spacing: AppSpacing.medium) {

            Text("Today's Progress")
                .font(AppTypography.title2)

            Text("\(completedTasks) of \(totalTasks) tasks completed")
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            ProgressView(value: progress)
                .tint(AppColors.accent)
        }
        .padding(AppSpacing.cardPadding)
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
    ProgressCard(
        completedTasks: 3,
        totalTasks: 8
    )
    .padding()
}
