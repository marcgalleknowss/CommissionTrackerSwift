//
//  CommissionController.swift
//  CommissionTracker
//
//  CONTROLLER layer (MVC). All business logic and data-writing
//  operations live here — creating, editing, deleting commissions,
//  advancing stages, handling revision limits, logging payments,
//  archiving, and auto-recording activity history.
//

import Foundation
import SwiftData

enum RevisionLogResult {
    case logged
    case limitReached
}

struct CommissionController {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - Create

    @discardableResult
    func addCommission(
        clientName: String,
        clientContact: String,
        price: Double,
        isDepositPaid: Bool,
        depositPercentage: Double,
        deadline: Date,
        revisionLimit: Int,
        notes: String
    ) -> Commission {
        let commission = Commission(
            clientName: clientName,
            clientContact: clientContact,
            price: price,
            isDepositPaid: isDepositPaid,
            depositPercentage: depositPercentage,
            deadline: deadline,
            revisionLimit: revisionLimit,
            notes: notes
        )
        context.insert(commission)
        logActivity(for: commission, detail: "Commission created")
        return commission
    }

    // MARK: - Update

    func updateCommission(
        _ commission: Commission,
        clientName: String,
        clientContact: String,
        price: Double,
        isDepositPaid: Bool,
        depositPercentage: Double,
        deadline: Date,
        revisionLimit: Int,
        notes: String
    ) {
        commission.clientName = clientName
        commission.clientContact = clientContact
        commission.price = price
        commission.isDepositPaid = isDepositPaid
        commission.depositPercentage = depositPercentage
        commission.deadline = deadline
        commission.revisionLimit = revisionLimit
        commission.notes = notes
    }

    // MARK: - Delete

    func deleteCommission(_ commission: Commission) {
        context.delete(commission)
    }

    func deleteAllCommissions(_ commissions: [Commission]) {
        for commission in commissions {
            context.delete(commission)
        }
    }

    // MARK: - Archive (NEW)

    func archiveCommission(_ commission: Commission) {
        commission.isArchived = true
        logActivity(for: commission, detail: "Archived")
    }

    func restoreCommission(_ commission: Commission) {
        commission.isArchived = false
        logActivity(for: commission, detail: "Restored from archive")
    }

    // MARK: - Stage progression

    func advanceStage(for commission: Commission) {
        let stages = CommissionStage.allCases
        let nextIndex = min(commission.stage.stepIndex + 1, stages.count - 1)
        commission.stage = stages[nextIndex]

        // Record the delivery date once it reaches the final stage —
        // used later by the Dashboard for earnings/turnaround stats.
        if commission.stage == .delivered {
            commission.deliveredDate = .now
        }

        logActivity(for: commission, detail: "Moved to \(commission.stage.rawValue)")
    }

    // MARK: - Revision handling

    func logRevision(for commission: Commission) -> RevisionLogResult {
        if commission.hasReachedRevisionLimit {
            return .limitReached
        }
        commission.revisionsUsed += 1
        logActivity(for: commission, detail: "Revision logged (\(commission.revisionsUsed)/\(commission.revisionLimit))")
        return .logged
    }

    func resolveRevisionLimitException(for commission: Commission) {
        commission.revisionsUsed += 1
        logActivity(for: commission, detail: "Revision logged past limit")
    }

    // MARK: - Payments (NEW)

    @discardableResult
    func logPayment(for commission: Commission, amount: Double, date: Date, label: String) -> Payment {
        let payment = Payment(amount: amount, date: date, label: label, commission: commission)
        context.insert(payment)
        logActivity(for: commission, detail: "Payment of \(Int(amount)) logged\(label.isEmpty ? "" : " (\(label))")")
        return payment
    }

    func deletePayment(_ payment: Payment) {
        context.delete(payment)
    }

    // MARK: - Activity log (NEW, private helper)

    private func logActivity(for commission: Commission, detail: String) {
        let entry = ActivityLogEntry(detail: detail, commission: commission)
        context.insert(entry)
    }
}
