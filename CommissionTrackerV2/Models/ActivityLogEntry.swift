//
//  ActivityLogEntry.swift
//  CommissionTracker
//
//  A single auto-logged event for a commission's activity timeline
//  (e.g. "Moved to Coloring", "Revision logged", "Payment logged").
//  These are created automatically by CommissionController — never
//  typed manually by the artist.
//

import Foundation
import SwiftData

@Model
final class ActivityLogEntry {
    var timestamp: Date
    var detail: String
    var commission: Commission?

    init(timestamp: Date = .now, detail: String, commission: Commission? = nil) {
        self.timestamp = timestamp
        self.detail = detail
        self.commission = commission
    }
}
