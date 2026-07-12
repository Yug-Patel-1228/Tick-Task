//
//  SearchBar.swift
//  TickTask
//
//  Created by Yug on 12/07/26.
//

import SwiftUI

struct SearchBar: View {

    @Binding var text: String

    var body: some View {

        HStack(spacing: AppSpacing.small) {

            Image(systemName: AppSymbols.search)
                .foregroundStyle(AppColors.textSecondary)

            TextField("Search tasks", text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {

                Button {

                    text = ""

                } label: {

                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textSecondary)

                }
            }
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.vertical, 12)
        .background(AppColors.secondaryBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppSpacing.cornerRadius,
                style: .continuous
            )
        )
    }
}

#Preview {

    @Previewable @State var text = ""

    SearchBar(text: $text)
        .padding()
}
