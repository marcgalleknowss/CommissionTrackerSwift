//
//  RootView.swift
//  CommissionTracker
//
//  Controls the top-level app flow:
//  Splash (brief loading) -> Get Started -> Artist Name -> Home
//  Once onboarding is completed once, the app always opens
//  straight to Home on future launches.
//
//  @AppStorage is a SwiftUI property wrapper that reads/writes
//  directly to UserDefaults — perfect for small bits of local
//  state like "artist name" or "has onboarded" that don't need
//  a full database model.
//

import SwiftUI

struct RootView: View {
    // Persisted locally on-device. No account/login system at all.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("artistName") private var artistName = ""

    // Controls the brief splash screen shown on every cold launch.
    @State private var isShowingSplash = true

    var body: some View {
        Group {
            if isShowingSplash {
                SplashView()
                    .task {
                        // Simulate a brief load (e.g. warming up SwiftData).
                        // Replace with real setup work if needed later.
                        try? await Task.sleep(nanoseconds: 900_000_000)
                        isShowingSplash = false
                    }
            } else if !hasCompletedOnboarding {
                // First-time flow: Get Started -> enter artist name.
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

// Groups the two onboarding screens together so RootView stays clean.
struct OnboardingFlowView: View {
    @Binding var artistName: String
    @Binding var hasCompletedOnboarding: Bool

    // Local navigation step: .getStarted shown first, then .nameEntry.
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
