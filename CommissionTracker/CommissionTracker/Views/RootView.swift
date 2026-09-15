//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
//

import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("artistName") private var artistName = ""
    @State private var isShowingSplash = true

    var body: some View {
        Group {
            if isShowingSplash {
                SplashView()
                    .task {
                        try? await Task.sleep(nanoseconds: 900_000_000)
                        isShowingSplash = false
                    }
            } else if !hasCompletedOnboarding {
                OnboardingFlowView(
                    artistName: $artistName,
                    hasCompletedOnboarding: $hasCompletedOnboarding
                )
            } else {
                HomeView(artistName: artistName)
            }
        }
    }
}

struct OnboardingFlowView: View {
    @Binding var artistName: String
    @Binding var hasCompletedOnboarding: Bool
    @State private var step: Step = .getStarted

    enum Step {
        case getStarted
        case nameEntry
    }

    var body: some View {
        switch step {
        case .getStarted:
            GetStartedView(onGetStarted: { step = .nameEntry })
        case .nameEntry:
            ArtistNameView(
                artistName: $artistName,
                onContinue: { hasCompletedOnboarding = true }
            )
        }
    }
}
