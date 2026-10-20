//
//  ClientListView.swift
//  CommissionTrackerV2
//
//  Lists every client with their commission count and lifetime value.
//  Clients found in existing commissions are added automatically the
//  first time this screen appears; more can be added with "+".
//

import SwiftUI
import SwiftData

struct ClientListView: View {
    @Query(sort: \Client.name) private var clients: [Client]
    @Query private var commissions: [Commission]
    @Environment(\.modelContext) private var context

    @State private var isShowingAddSheet = false

    private var controller: ClientController {
        ClientController(context: context)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Theme.background.ignoresSafeArea()

                if clients.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: Theme.cardSpacing) {
                            ForEach(clients) { client in
                                NavigationLink {
                                    ClientDetailView(client: client)
                                } label: {
                                    ClientCardView(
                                        client: client,
                                        commissionCount: controller.commissions(for: client, from: commissions).count,
                                        lifetimeValue: controller.totalLifetimeValue(for: client, from: commissions)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, Theme.screenMargin)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }

                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Circle().fill(Theme.textPrimary))
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                }
                .padding(.trailing, Theme.screenMargin)
                .padding(.bottom, 24)
            }
            .navigationTitle("Clients")
            .sheet(isPresented: $isShowingAddSheet) {
                AddEditClientView(client: nil)
            }
            .onAppear(perform: syncClientsFromCommissions)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2")
                .font(.system(size: 36, weight: .thin))
                .foregroundStyle(Theme.textSecondary)
            Text("No clients yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Creates a Client record for any client name that appears in a
    // commission but has no saved client yet.
    private func syncClientsFromCommissions() {
        let existingNames = Set(clients.map { $0.name })
        for name in Set(commissions.map { $0.clientName }) where !name.isEmpty && !existingNames.contains(name) {
            let contact = commissions.first(where: { $0.clientName == name })?.clientContact ?? ""
            controller.addClient(name: name, contact: contact, notes: "")
        }
    }
}

struct ClientCardView: View {
    let client: Client
    let commissionCount: Int
    let lifetimeValue: Double

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(client.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                Text("\(commissionCount) commission\(commissionCount == 1 ? "" : "s")")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(lifetimeValue, format: .currency(code: "PHP"))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(Theme.textPrimary)
                Text("lifetime value")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .cardStyle()
    }
}

#Preview {
    ClientListView()
        .modelContainer(for: [Commission.self, Client.self, Payment.self, PricingPackage.self, ActivityLogEntry.self], inMemory: true)
}
