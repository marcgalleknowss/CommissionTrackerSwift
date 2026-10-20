//
//  DashboardView.swift
//  CommissionTrackerV2
//
//  Read-only overview: earnings, monthly goal, average turnaround,
//  commissions per stage, and top clients. Everything is computed from
//  the commissions already stored on the device.
//

import SwiftUI
import SwiftData

private struct StageCount: Identifiable {
    let stage: CommissionStage
    let count: Int
    var id: String { stage.rawValue }
}

private struct ClientStat: Identifiable {
    let name: String
    let count: Int
    var id: String { name }
}

struct DashboardView: View {
    @Query private var commissions: [Commission]
    @AppStorage("monthlyGoal") private var monthlyGoal = 5

    // MARK: - Computed stats

    private var delivered: [Commission] {
        commissions.filter { $0.isDelivered }
    }

    private var totalEarnings: Double {
        delivered.reduce(0) { $0 + $1.price }
    }

    private var deliveredThisMonth: [Commission] {
        delivered.filter { commission in
            guard let date = commission.deliveredDate else { return false }
            return Calendar.current.isDate(date, equalTo: .now, toGranularity: .month)
        }
    }

    private var earningsThisMonth: Double {
        deliveredThisMonth.reduce(0) { $0 + $1.price }
    }

    private var averageTurnaroundDays: Double? {
        let durations = delivered.compactMap { commission -> Double? in
            guard let end = commission.deliveredDate else { return nil }
            let days = Calendar.current.dateComponents([.day], from: commission.dateCreated, to: end).day ?? 0
            return Double(days)
        }
        guard !durations.isEmpty else { return nil }
        return durations.reduce(0, +) / Double(durations.count)
    }

    private var stageCounts: [StageCount] {
        CommissionStage.allCases.map { stage in
            StageCount(stage: stage, count: commissions.filter { $0.stage == stage }.count)
        }
    }

    private var topClients: [ClientStat] {
        let grouped = Dictionary(grouping: commissions, by: { $0.clientName })
        let stats = grouped.map { ClientStat(name: $0.key, count: $0.value.count) }
        return Array(stats.sorted { $0.count > $1.count }.prefix(3))
    }

    private func money(_ value: Double) -> String {
        value.formatted(.currency(code: "PHP"))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    earningsCard
                    goalCard
                    turnaroundCard
                    stageCard
                    topClientsCard
                }
                .padding(Theme.screenMargin)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Dashboard")
        }
    }

    // MARK: - Cards

    private var earningsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Earnings")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)

            Text(money(totalEarnings))
                .font(.system(size: 34, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Theme.textPrimary)

            Divider().background(Theme.divider)

            HStack {
                Text("This Month")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text(money(earningsThisMonth))
                    .font(.system(size: 14, weight: .medium))
                    .monospacedDigit()
                    .foregroundStyle(Theme.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Goal")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 16) {
                RevisionRingView(
                    used: deliveredThisMonth.count,
                    limit: max(monthlyGoal, 1)
                )
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(deliveredThisMonth.count) of \(monthlyGoal) delivered")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    Text("this month")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
            }

            Stepper("Goal: \(monthlyGoal) commissions", value: $monthlyGoal, in: 1...50)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var turnaroundCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Average Turnaround")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                if let days = averageTurnaroundDays {
                    Text(String(format: "%.1f days", days))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                } else {
                    Text("No data yet")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Spacer()
            Image(systemName: "clock")
                .font(.system(size: 24, weight: .thin))
                .foregroundStyle(Theme.textSecondary)
        }
        .cardStyle()
    }

    private var stageCard: some View {
        let maxCount = max(stageCounts.map { $0.count }.max() ?? 1, 1)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Commissions by Stage")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)

            ForEach(stageCounts) { item in
                HStack(spacing: 10) {
                    Text(item.stage.rawValue)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textPrimary)
                        .frame(width: 70, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.badgeInactive.opacity(0.5))
                            Capsule()
                                .fill(Theme.textPrimary)
                                .frame(width: geo.size.width * CGFloat(item.count) / CGFloat(maxCount))
                        }
                    }
                    .frame(height: 8)

                    Text("\(item.count)")
                        .font(.system(size: 13, weight: .medium))
                        .monospacedDigit()
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 24, alignment: .trailing)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    private var topClientsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Clients")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.textSecondary)

            if topClients.isEmpty {
                Text("No clients yet")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
            } else {
                ForEach(topClients) { client in
                    HStack {
                        Text(client.name)
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Text("\(client.count) commission\(client.count == 1 ? "" : "s")")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Commission.self, Client.self, Payment.self, PricingPackage.self, ActivityLogEntry.self], inMemory: true)
}
