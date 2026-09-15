//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
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
        dateCreated: Date = .now
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
    }

    var isDelivered: Bool { stage == .delivered }
    var hasReachedRevisionLimit: Bool { revisionsUsed >= revisionLimit }
    var balanceDue: Double {
        price - (price * (isDepositPaid ? depositPercentage / 100 : 0))
    }
}
