//
//  CommissionDetailView.swift
//  CommissionTrackerV2
//
//  One commission in full: client info, stage tracker, revision counter,
//  payments summary, notes, and an auto-logged activity timeline.
//  Also handles archive / restore / delete.
//

import SwiftUI
import SwiftData

struct CommissionDetailView: View {
    @Bindable var commission: Commission

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingEditSheet = false
    @State private var isShowingSummary = false
    @State private var isShowingRevisionLimitAlert = false
    @State private var isShowingDeleteConfirmation = false

    // All writes go through the Controller (MVC: View -> Controller -> Model).
    private var controller: CommissionController {
        CommissionController(context: context)
    }

    private var sortedActivity: [ActivityLogEntry] {
        commission.activityLog.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: Client info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(commission.clientName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        if commission.isArchived {
                            Text("Archived")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Theme.badgeInactive))
                        }
                    }

                    if !commission.clientContact.isEmpty {
                        Text(commission.clientContact)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                    }

                    HStack {
                        Label(commission.deadline.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        Spacer()
                        Text(commission.price, format: .currency(code: "PHP"))
                            .monospacedDigit()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()

                // MARK: Stage progress
                VStack(alignment: .leading, spacing: 12) {
                    Text("Progress")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)

                    StageTrackerView(currentStage: commission.stage)

                    if commission.stage != .delivered {
                        Button {
                            controller.advanceStage(for: commission)
                        } label: {
                            Text("Mark as \(nextStageLabel)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Theme.textPrimary))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()

                // MARK: Revisions
                HStack(spacing: 16) {
                    RevisionRingView(
                        used: commission.revisionsUsed,
                        limit: max(commission.revisionLimit, 1)
                    )
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Revisions")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.textPrimary)
                        Text("\(commission.revisionsUsed) of \(commission.revisionLimit) used")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Spacer()

                    Button {
                        logRevisionRequest()
                    } label: {
                        Text("Log Revision")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .overlay(Capsule().stroke(Theme.stroke, lineWidth: 1))
                    }
                }
                .cardStyle()

                // MARK: Payments (opens Payment History)
                NavigationLink {
                    PaymentHistoryView(commission: commission)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Payments")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Theme.textPrimary)
                            Text("\(commission.totalPaid.formatted(.currency(code: "PHP"))) of \(commission.price.formatted(.currency(code: "PHP"))) paid")
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .cardStyle()
                }
                .buttonStyle(.plain)

                // MARK: Notes
                if !commission.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                        Text(commission.notes)
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardStyle()
                }

                // MARK: Activity timeline (auto-logged by the Controller)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)

                    if sortedActivity.isEmpty {
                        Text("No activity yet")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                    } else {
                        ForEach(sortedActivity) { entry in
                            HStack(alignment: .top, spacing: 12) {
                                Circle()
                                    .fill(Theme.textPrimary)
                                    .frame(width: 8, height: 8)
                                    .padding(.top, 5)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.detail)
                                        .font(.system(size: 14))
                                        .foregroundStyle(Theme.textPrimary)
                                    Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                                        .font(.system(size: 12))
                                        .foregroundStyle(Theme.textSecondary)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
            }
            .padding(Theme.screenMargin)
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Edit") { isShowingEditSheet = true }
                    Button("View Summary") { isShowingSummary = true }
                    if commission.isArchived {
                        Button("Restore") { controller.restoreCommission(commission) }
                    } else {
                        Button("Archive") {
                            controller.archiveCommission(commission)
                            dismiss()
                        }
                    }
                    Button("Delete", role: .destructive) { isShowingDeleteConfirmation = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            AddEditCommissionView(commission: commission)
        }
        .sheet(isPresented: $isShowingSummary) {
            SummaryView(commission: commission)
        }
        .alert("Revision Limit Reached", isPresented: $isShowingRevisionLimitAlert) {
            Button("Log as Paid Revision") {
                controller.resolveRevisionLimitException(for: commission)
            }
            Button("Allow as Exception") {
                controller.resolveRevisionLimitException(for: commission)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(commission.clientName) has used all \(commission.revisionLimit) included revisions.")
        }
        .confirmationDialog(
            "Delete this commission?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { deleteCommission() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This also removes its payments and activity history. Archiving keeps everything.")
        }
    }

    private var nextStageLabel: String {
        let stages = CommissionStage.allCases
        let nextIndex = min(commission.stage.stepIndex + 1, stages.count - 1)
        return stages[nextIndex].rawValue
    }

    private func logRevisionRequest() {
        let result = controller.logRevision(for: commission)
        if result == .limitReached {
            isShowingRevisionLimitAlert = true
        }
    }

    // Leave the screen first, then delete, so this view never tries to
    // read a commission that no longer exists.
    private func deleteCommission() {
        let controller = self.controller
        let target = commission
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            controller.deleteCommission(target)
        }
    }
}

// MARK: - Horizontal stage tracker (dots connected by lines)
struct StageTrackerView: View {
    let currentStage: CommissionStage

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(CommissionStage.allCases.enumerated()), id: \.element) { index, stage in
                let isCompleted = stage.stepIndex <= currentStage.stepIndex

                VStack(spacing: 6) {
                    Circle()
                        .fill(isCompleted ? Theme.textPrimary : Theme.badgeInactive)
                        .frame(width: 10, height: 10)

                    Text(stage.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(isCompleted ? Theme.textPrimary : Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)

                if index < CommissionStage.allCases.count - 1 {
                    Rectangle()
                        .fill(isCompleted ? Theme.textPrimary : Theme.badgeInactive)
                        .frame(height: 1)
                        .offset(y: -8)
                }
            }
        }
    }
}

// MARK: - Circular ring (monochrome). Also reused by the Dashboard goal card.
struct RevisionRingView: View {
    let used: Int
    let limit: Int

    private var progress: Double {
        min(Double(used) / Double(limit), 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.badgeInactive, lineWidth: 6)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Theme.textPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(used)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

#Preview {
    NavigationStack {
        CommissionDetailView(
            commission: Commission(clientName: "Jane Dela Cruz", price: 1500, deadline: .now)
        )
    }
    .modelContainer(for: [Commission.self, Client.self, Payment.self, PricingPackage.self, ActivityLogEntry.self], inMemory: true)
}
