//
//  EmptyState.swift
//  TickTask
//

import SwiftUI

struct EmptyState: View {

    var body: some View {

        VStack(spacing: AppSpacing.large) {

            Image(systemName: AppSymbols.empty)
                .font(.system(size: 60))
                .foregroundStyle(AppColors.accent)

            VStack(spacing: AppSpacing.small) {

                Text("No Tasks Yet")
                    .font(AppTypography.title2)

                Text("Tap the + button to create your first task.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal)
    }
}

#Preview {
    EmptyState()
}
