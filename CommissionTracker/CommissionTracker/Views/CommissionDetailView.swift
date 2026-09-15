//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
//

import SwiftUI
import SwiftData

struct CommissionDetailView: View {
    @Bindable var commission: Commission

    @Environment(\.modelContext) private var context
    @State private var isShowingEditSheet = false
    @State private var isShowingSummary = false
    @State private var isShowingRevisionLimitAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: Client info card
                VStack(alignment: .leading, spacing: 8) {
                    Text(commission.clientName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

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
                .cardStyle()

                // MARK: Stage progress tracker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Progress")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.textSecondary)

                    StageTrackerView(currentStage: commission.stage)

                    if commission.stage != .delivered {
                        Button {
                            advanceStage()
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
                .cardStyle()

                // MARK: Revision counter (circular ring, monochrome)
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
                    .cardStyle()
                }
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
                    Button("Delete", role: .destructive) { deleteCommission() }
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
    }

    private var nextStageLabel: String {
        let stages = CommissionStage.allCases
        let nextIndex = min(commission.stage.stepIndex + 1, stages.count - 1)
        return stages[nextIndex].rawValue
    }

    
    private var controller: CommissionController {
        CommissionController(context: context)
    }

    private func advanceStage() {
        controller.advanceStage(for: commission)
    }

    private func logRevisionRequest() {
        let result = controller.logRevision(for: commission)
        if result == .limitReached {
            isShowingRevisionLimitAlert = true
        }
    }

    private func deleteCommission() {
        controller.deleteCommission(commission)
    }
}

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
    .modelContainer(for: Commission.self, inMemory: true)
}
