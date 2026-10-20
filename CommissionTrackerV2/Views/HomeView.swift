//
//  HomeView.swift
//  CommissionTrackerV2
//
//  Tab container (Home, Dashboard, Clients, Settings) plus the main
//  commission list with an All / In Progress / Delivered / Archived filter.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    let artistName: String

    var body: some View {
        TabView {
            CommissionListView(artistName: artistName)
                .tabItem { Label("Home", systemImage: "house") }

            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar") }

            ClientListView()
                .tabItem { Label("Clients", systemImage: "person.2") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(Theme.textPrimary)
    }
}

private enum CommissionFilter: String, CaseIterable {
    case all = "All"
    case inProgress = "In Progress"
    case delivered = "Delivered"
    case archived = "Archived"
}

struct CommissionListView: View {
    let artistName: String

    @Query(sort: \Commission.deadline) private var commissions: [Commission]

    @State private var filter: CommissionFilter = .all
    @State private var isShowingAddSheet = false

    private var filteredCommissions: [Commission] {
        switch filter {
        case .all:
            return commissions.filter { !$0.isArchived }
        case .inProgress:
            return commissions.filter { !$0.isArchived && $0.stage != .delivered }
        case .delivered:
            return commissions.filter { !$0.isArchived && $0.stage == .delivered }
        case .archived:
            return commissions.filter { $0.isArchived }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("Filter", selection: $filter) {
                        ForEach(CommissionFilter.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, Theme.screenMargin)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    if filteredCommissions.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Theme.cardSpacing) {
                                ForEach(filteredCommissions) { commission in
                                    NavigationLink {
                                        CommissionDetailView(commission: commission)
                                    } label: {
                                        CommissionCardView(commission: commission)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, Theme.screenMargin)
                            .padding(.bottom, 100)
                        }
                    }
                }
                .navigationTitle(artistName.isEmpty ? "Commissions" : "Hi, \(artistName)")

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
            .sheet(isPresented: $isShowingAddSheet) {
                AddEditCommissionView(commission: nil)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: filter == .archived ? "archivebox" : "tray")
                .font(.system(size: 36, weight: .thin))
                .foregroundStyle(Theme.textSecondary)
            Text(filter == .archived ? "No archived commissions" : "No commissions yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// A single commission card. Also reused by ClientDetailView.
struct CommissionCardView: View {
    let commission: Commission

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(commission.clientName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)

                Text(commission.deadline, style: .date)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Theme.textSecondary)

                Text(commission.stage.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(commission.isDelivered ? Theme.textSecondary : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(commission.isDelivered ? Theme.badgeInactive : Theme.badgeActive)
                    )
            }

            Spacer()

            Text(commission.price, format: .currency(code: "PHP"))
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Theme.textPrimary)
        }
        .cardStyle()
    }
}

#Preview {
    HomeView(artistName: "Mink")
        .modelContainer(for: [Commission.self, Client.self, Payment.self, PricingPackage.self, ActivityLogEntry.self], inMemory: true)
}
