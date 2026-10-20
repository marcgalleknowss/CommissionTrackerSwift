//
//  GetStartedView.swift
//  CommissionTracker
//
//  First screen a brand-new user sees. No account creation —
//  just a tagline and a button that moves to the name entry step.
//

import SwiftUI

struct GetStartedView: View {
    // Called when the user taps "Get Started" — RootView/OnboardingFlowView
    // decides what happens next (moves to ArtistNameView).
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Minimal line-art style icon using SF Symbols,
                // kept monochrome to match the grayscale palette.
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
