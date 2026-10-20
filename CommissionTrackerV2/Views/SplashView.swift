//
//  SplashView.swift
//  CommissionTracker
//
//  Minimal loading screen shown briefly on every cold launch.
//  Purely visual — RootView controls how long it stays on screen.
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

                // Native iOS spinner — thin, minimal, matches system style.
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
