//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Commission Tracker")
                    .font(.system(size: 28, weight: .semibold, design: .default))
                    .foregroundStyle(Theme.textPrimary)

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Theme.textSecondary)
            }
        }
    }
}

#Preview {
    SplashView()
}
