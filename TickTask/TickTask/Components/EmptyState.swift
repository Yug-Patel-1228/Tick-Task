//
//  EmptyState.swift
//  TickTask
//

import SwiftUI

struct EmptyState: View {

    let title: String
    let message: String
    let buttonTitle: String?
    let action: (() -> Void)?

    init(
        title: String = "No Tasks",
        message: String = "Tap + to add your first task",
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }

    var body: some View {

        VStack(spacing: AppSpacing.large) {

            Image(systemName: AppSymbols.empty)
                .font(.system(size: 60))
                .foregroundStyle(AppColors.accent)

            VStack(spacing: AppSpacing.small) {

                Text(title)
                    .font(AppTypography.title2)

                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let buttonTitle, let action {
                Button(action: action) {
                    Label(buttonTitle, systemImage: AppSymbols.add)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityIdentifier("CreateTaskEmptyStateButton")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

#Preview {
    EmptyState()
}
