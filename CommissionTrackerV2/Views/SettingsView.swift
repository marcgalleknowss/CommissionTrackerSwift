//
//  SettingsView.swift
//  CommissionTrackerV2
//
//  Display name, pricing packages, and a delete-all option.
//  No profile, no login, no notification settings.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("artistName") private var artistName = ""
    @Environment(\.modelContext) private var context
    @Query private var commissions: [Commission]

    @State private var isShowingResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Display Name") {
                    TextField("Your name", text: $artistName)
                }

                Section {
                    NavigationLink("Manage Packages") {
                        ManagePackagesView()
                    }
                } header: {
                    Text("Pricing")
                } footer: {
                    Text("Saved packages auto-fill the price and revision limit when you add a commission.")
                }

                Section {
                    Button(role: .destructive) {
                        isShowingResetConfirmation = true
                    } label: {
                        Text("Delete All Commissions")
                    }
                } footer: {
                    Text("This app stores everything only on this device. Deleting data here cannot be undone.")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Delete all \(commissions.count) commissions?",
                isPresented: $isShowingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete All", role: .destructive) {
                    CommissionController(context: context).deleteAllCommissions(commissions)
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Commission.self, Client.self, Payment.self, PricingPackage.self, ActivityLogEntry.self], inMemory: true)
}
