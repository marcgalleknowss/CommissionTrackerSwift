//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
//

import SwiftUI
import SwiftData

@main
struct CommissionTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: Commission.self)
    }
}
