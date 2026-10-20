//
//  Payment.swift
//  CommissionTracker
//
//  A single logged payment against one commission — lets an artist
//  track installment/partial payments over time, instead of just a
//  single deposit/balance split.
//

import Foundation
import SwiftData

@Model
final class Payment {
    var amount: Double
    var date: Date
    var label: String // e.g. "Deposit", "Milestone 2", "Final Payment"
    var commission: Commission?

    init(
        amount: Double,
        date: Date = .now,
        label: String = "",
        commission: Commission? = nil
    ) {
        self.amount = amount
        self.date = date
        self.label = label
        self.commission = commission
    }
}
