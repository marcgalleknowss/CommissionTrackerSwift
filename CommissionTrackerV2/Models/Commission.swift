//
//  Commission.swift
//  CommissionTracker
//
//  Core data model. Using SwiftData means everything is persisted
//  locally on-device automatically (no backend, no network needed —
//  the whole app is offline by design).
//

import Foundation
import SwiftData

enum CommissionStage: String, Codable, CaseIterable, Identifiable {
    case sketch = "Sketch"
    case lineart = "Lineart"
    case coloring = "Coloring"
    case final = "Final"
    case delivered = "Delivered"

    var id: String { rawValue }

    var stepIndex: Int {
        CommissionStage.allCases.firstIndex(of: self) ?? 0
    }
}

@Model
final class Commission {
    var clientName: String
    var clientContact: String
    var price: Double

    var isDepositPaid: Bool
    var depositPercentage: Double

    var deadline: Date

    var revisionLimit: Int
    var revisionsUsed: Int

    private var stageRawValue: String
    var stage: CommissionStage {
        get { CommissionStage(rawValue: stageRawValue) ?? .sketch }
        set { stageRawValue = newValue.rawValue }
    }

    var notes: String
    var dateCreated: Date

    // NEW: Archive support — instead of permanently deleting a
    // commission, it can be archived and hidden from the main list.
    var isArchived: Bool = false

    // NEW: Set automatically once the commission reaches .delivered.
    // Used by the Dashboard to compute "this month's earnings" and
    // average turnaround time.
    var deliveredDate: Date?

    // NEW: Every payment logged against this commission. Deleting a
    // commission also deletes its payments (cascade).
    @Relationship(deleteRule: .cascade, inverse: \Payment.commission)
    var payments: [Payment] = []

    // NEW: Auto-logged history of what happened to this commission
    // (stage changes, revisions, payments). Shown as a timeline.
    @Relationship(deleteRule: .cascade, inverse: \ActivityLogEntry.commission)
    var activityLog: [ActivityLogEntry] = []

    init(
        clientName: String,
        clientContact: String = "",
        price: Double,
        isDepositPaid: Bool = false,
        depositPercentage: Double = 0,
        deadline: Date,
        revisionLimit: Int = 2,
        revisionsUsed: Int = 0,
        stage: CommissionStage = .sketch,
        notes: String = "",
        dateCreated: Date = .now,
        isArchived: Bool = false,
        deliveredDate: Date? = nil
    ) {
        self.clientName = clientName
        self.clientContact = clientContact
        self.price = price
        self.isDepositPaid = isDepositPaid
        self.depositPercentage = depositPercentage
        self.deadline = deadline
        self.revisionLimit = revisionLimit
        self.revisionsUsed = revisionsUsed
        self.stageRawValue = stage.rawValue
        self.notes = notes
        self.dateCreated = dateCreated
        self.isArchived = isArchived
        self.deliveredDate = deliveredDate
    }

    var isDelivered: Bool { stage == .delivered }
    var hasReachedRevisionLimit: Bool { revisionsUsed >= revisionLimit }
    var balanceDue: Double {
        price - (price * (isDepositPaid ? depositPercentage / 100 : 0))
    }

    // NEW: Sum of every logged payment — used by Payment History screen.
    var totalPaid: Double {
        payments.reduce(0) { $0 + $1.amount }
    }
}
