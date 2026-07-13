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

            HStack {
                Text("Today's Progress")
                    .font(AppTypography.title2)

                Spacer()

                Text("\(completedTasks) / \(totalTasks)")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.accent)
            }

            Text("\(completedTasks) of \(totalTasks) completed today")
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.textSecondary)

            ProgressView(value: progress)
                .tint(AppColors.accent)
                .animation(.easeInOut(duration: 0.28), value: progress)
        }
        .padding(AppSpacing.cardPadding)
        .background(.thinMaterial)
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
