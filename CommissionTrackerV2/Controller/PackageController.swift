//
//  PackageController.swift
//  CommissionTracker
//
//  CONTROLLER layer for managing reusable pricing packages.
//

import Foundation
import SwiftData

struct PackageController {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func addPackage(name: String, price: Double, revisionLimit: Int) -> PricingPackage {
        let package = PricingPackage(name: name, price: price, revisionLimit: revisionLimit)
        context.insert(package)
        return package
    }

    func deletePackage(_ package: PricingPackage) {
        context.delete(package)
    }
}
