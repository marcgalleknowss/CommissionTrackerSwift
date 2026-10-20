//
//  CommissionTrackerV2App.swift
//  CommissionTrackerV2
//
//  App entry point. Registers every SwiftData model so all views can
//  query and save them, then hands over to RootView.
//

import SwiftUI
import SwiftData

@main
struct CommissionTrackerV2App: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            Commission.self,
            Client.self,
            Payment.self,
            PricingPackage.self,
            ActivityLogEntry.self
        ])
    }
}
