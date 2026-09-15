//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
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
        return commission
    }

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

    func deleteCommission(_ commission: Commission) {
        context.delete(commission)
    }

    func deleteAllCommissions(_ commissions: [Commission]) {
        for commission in commissions {
            context.delete(commission)
        }
    }

    func advanceStage(for commission: Commission) {
        let stages = CommissionStage.allCases
        let nextIndex = min(commission.stage.stepIndex + 1, stages.count - 1)
        commission.stage = stages[nextIndex]
    }

    func logRevision(for commission: Commission) -> RevisionLogResult {
        if commission.hasReachedRevisionLimit {
            return .limitReached
        }
        commission.revisionsUsed += 1
        return .logged
    }

    func resolveRevisionLimitException(for commission: Commission) {
        commission.revisionsUsed += 1
    }
}
