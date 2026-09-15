//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
//


import SwiftUI
import SwiftData

struct AddEditCommissionView: View {
    var commission: Commission?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var clientName: String = ""
    @State private var clientContact: String = ""
    @State private var priceText: String = ""
    @State private var isDepositPaid: Bool = false
    @State private var depositPercentage: Double = 0
    @State private var deadline: Date = .now
    @State private var revisionLimit: Int = 2
    @State private var notes: String = ""

    private var isEditing: Bool { commission != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Client") {
                    TextField("Client name", text: $clientName)
                    TextField("Contact (email or handle)", text: $clientContact)
                }

                Section("Pricing") {
                    TextField("Price", text: $priceText)
                        .keyboardType(.decimalPad)

                    Toggle("Deposit paid", isOn: $isDepositPaid)

                    if isDepositPaid {
                        Stepper(
                            "Deposit: \(Int(depositPercentage))%",
                            value: $depositPercentage,
                            in: 0...100,
                            step: 10
                        )
                    }
                }

                Section("Timeline") {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                    Stepper("Revision limit: \(revisionLimit)", value: $revisionLimit, in: 0...10)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditing ? "Edit Commission" : "New Commission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(clientName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear(perform: loadExistingValuesIfNeeded)
        }
    }

    private func loadExistingValuesIfNeeded() {
        guard let commission else { return }
        clientName = commission.clientName
        clientContact = commission.clientContact
        priceText = String(commission.price)
        isDepositPaid = commission.isDepositPaid
        depositPercentage = commission.depositPercentage
        deadline = commission.deadline
        revisionLimit = commission.revisionLimit
        notes = commission.notes
    }

    private func save() {
        let price = Double(priceText) ?? 0
        // All writes go through the Controller — this View never
        // touches modelContext directly (MVC: View -> Controller -> Model).
        let controller = CommissionController(context: context)

        if let commission {
            controller.updateCommission(
                commission,
                clientName: clientName,
                clientContact: clientContact,
                price: price,
                isDepositPaid: isDepositPaid,
                depositPercentage: depositPercentage,
                deadline: deadline,
                revisionLimit: revisionLimit,
                notes: notes
            )
        } else {
            controller.addCommission(
                clientName: clientName,
                clientContact: clientContact,
                price: price,
                isDepositPaid: isDepositPaid,
                depositPercentage: depositPercentage,
                deadline: deadline,
                revisionLimit: revisionLimit,
                notes: notes
            )
        }

        dismiss()
    }
}

#Preview {
    AddEditCommissionView(commission: nil)
        .modelContainer(for: Commission.self, inMemory: true)
}
