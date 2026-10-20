//
//  ClientDetailView.swift
//  CommissionTrackerV2
//
//  One client: contact info, lifetime value, and every commission linked
//  to them. Includes a shortcut to add a new commission for this client.
//

import SwiftUI
import SwiftData

struct ClientDetailView: View {
    let client: Client

    @Query(sort: \Commission.deadline) private var allCommissions: [Commission]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingAddCommission = false
    @State private var isShowingEditClient = false
    @State private var isShowingDeleteConfirmation = false

    private var controller: ClientController {
        ClientController(context: context)
    }

    private var clientCommissions: [Commission] {
        controller.commissions(for: client, from: allCommissions)
    }

    private var lifetimeValue: Double {
        controller.totalLifetimeValue(for: client, from: allCommissions)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: Client info
                VStack(alignment: .leading, spacing: 8) {
                    Text(client.name)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    if !client.contact.isEmpty {
                        Text(client.contact)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Divider().background(Theme.divider)

                    HStack {
                        Text("Lifetime value")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                        Spacer()
                        Text(lifetimeValue, format: .currency(code: "PHP"))
                            .font(.system(size: 15, weight: .semibold))
                            .monospacedDigit()
                            .foregroundStyle(Theme.textPrimary)
                    }

                    if !client.notes.isEmpty {
                        Text(client.notes)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()

                // MARK: Linked commissions
                Text("Commissions")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)

                if clientCommissions.isEmpty {
                    Text("No commissions for this client yet")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    VStack(spacing: Theme.cardSpacing) {
                        ForEach(clientCommissions) { commission in
                            NavigationLink {
                                CommissionDetailView(commission: commission)
                            } label: {
                                CommissionCardView(commission: commission)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // MARK: Add commission for this client
                Button {
                    isShowingAddCommission = true
                } label: {
                    Text("Add Commission for this Client")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                                .fill(Theme.textPrimary)
                        )
                }
            }
            .padding(Theme.screenMargin)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Edit Client") { isShowingEditClient = true }
                    Button("Delete Client", role: .destructive) { isShowingDeleteConfirmation = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingAddCommission) {
            AddEditCommissionView(commission: nil, prefilledClient: client)
        }
        .sheet(isPresented: $isShowingEditClient) {
            AddEditClientView(client: client)
        }
        .confirmationDialog(
            "Delete this client?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Client", role: .destructive) { deleteClient() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Their commissions are kept. Only the client profile is removed.")
        }
    }

    private func deleteClient() {
        let controller = self.controller
        let target = client
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            controller.deleteClient(target)
        }
    }
}
