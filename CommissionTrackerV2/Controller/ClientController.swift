//
//  ClientController.swift
//  CommissionTracker
//
//  CONTROLLER layer for Client CRUD, plus helper functions that
//  aggregate a client's related commissions (matched by name).
//

import Foundation
import SwiftData

struct ClientController {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func addClient(name: String, contact: String, notes: String) -> Client {
        let client = Client(name: name, contact: contact, notes: notes)
        context.insert(client)
        return client
    }

    func updateClient(_ client: Client, name: String, contact: String, notes: String) {
        client.name = name
        client.contact = contact
        client.notes = notes
    }

    func deleteClient(_ client: Client) {
        context.delete(client)
    }

    // Commissions belonging to this client, matched by client name.
    func commissions(for client: Client, from all: [Commission]) -> [Commission] {
        all.filter { $0.clientName == client.name }
    }

    func totalLifetimeValue(for client: Client, from all: [Commission]) -> Double {
        commissions(for: client, from: all).reduce(0) { $0 + $1.price }
    }
}
