//
//  PricingPackage.swift
//  CommissionTracker
//
//  A reusable pricing template (e.g. "Sketch Only — ₱500") the
//  artist can define once and quickly apply when adding a new
//  commission, instead of typing the price/revision limit every time.
//

import Foundation
import SwiftData

@Model
final class PricingPackage {
    var name: String
    var price: Double
    var revisionLimit: Int

    init(name: String, price: Double, revisionLimit: Int = 2) {
        self.name = name
        self.price = price
        self.revisionLimit = revisionLimit
    }
}
