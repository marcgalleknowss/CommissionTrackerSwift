//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
//


import SwiftUI

struct GetStartedView: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "paintbrush.pointed")
                    .font(.system(size: 44, weight: .thin))
                    .foregroundStyle(Theme.textSecondary)

                Text("Commission Tracker")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)

                Text("Manage your commissions, simply.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)

                Spacer()

                Button(action: onGetStarted) {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                                .fill(Theme.textPrimary) // near-black button, grayscale only
                        )
                }
                .padding(.horizontal, Theme.screenMargin)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, Theme.screenMargin)
        }
    }
}

#Preview {
    GetStartedView(onGetStarted: {})
}
