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
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(AppColors.accent)
                .clipShape(Circle())
                .shadow(radius: 8)
        }
    }
}

#Preview {

    FloatingButton {

    }
}
