//
//  Client.swift
//  CommissionTracker
//
//  Represents a client profile — separate from Commission so an
//  artist can store contact info/notes about a client once, instead
//  of retyping it for every new commission. Matched to commissions
//  by name (simple, no complex relationship needed).
//

import Foundation
import SwiftData

@Model
final class Client {
    var name: String
    var contact: String
    var notes: String
    var dateCreated: Date

    init(
        name: String,
        contact: String = "",
        notes: String = "",
        dateCreated: Date = .now
    ) {
        self.name = name
        self.contact = contact
        self.notes = notes
        self.dateCreated = dateCreated
    }
}
