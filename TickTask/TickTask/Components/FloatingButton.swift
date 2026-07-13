//
//  FloatingButton.swift
//  TickTask
//

import SwiftUI

struct FloatingButton: View {

    let action: () -> Void

    var body: some View {

        Button(action: action) {

            Image(systemName: AppSymbols.add)
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(AppColors.accent.gradient)
                .clipShape(Circle())
                .shadow(radius: 8)
        }
        .accessibilityLabel("Add Task")
    }
}

#Preview {

    FloatingButton {

    }
}
