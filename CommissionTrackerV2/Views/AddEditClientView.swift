//
//  AddEditClientView.swift
//  CommissionTrackerV2
//
//  Form for adding a new client or editing an existing one.
//  The name is locked when editing because commissions are linked to
//  a client by name.
//

import SwiftUI
import SwiftData

struct AddEditClientView: View {
    var client: Client?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var clients: [Client]

    @State private var name: String = ""
    @State private var contact: String = ""
    @State private var notes: String = ""

    private var isEditing: Bool { client != nil }
    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var isDuplicate: Bool {
        !isEditing && clients.contains { $0.name == trimmedName }
    }
    private var canSave: Bool { !trimmedName.isEmpty && !isDuplicate }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Client name", text: $name)
                        .disabled(isEditing)
                    TextField("Contact (email or handle)", text: $contact)
                } footer: {
                    if isDuplicate {
                        Text("A client with this name already exists.")
                    } else if isEditing {
                        Text("Name can't be changed because commissions are linked to it by name.")
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditing ? "Edit Client" : "New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
            .onAppear {
                if let client {
                    name = client.name
                    contact = client.contact
                    notes = client.notes
                }
            }
        }
    }

    private func save() {
        let controller = ClientController(context: context)
        if let client {
            controller.updateClient(client, name: client.name, contact: contact, notes: notes)
        } else {
            controller.addClient(name: trimmedName, contact: contact, notes: notes)
        }
        dismiss()
    }
}

#Preview {
    AddEditClientView(client: nil)
        .modelContainer(for: [Commission.self, Client.self, Payment.self, PricingPackage.self, ActivityLogEntry.self], inMemory: true)
}
