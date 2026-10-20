//
//  AddEditCommissionView.swift
//  CommissionTrackerV2
//
//  One form for creating AND editing a commission. When creating, the
//  artist can pick a saved pricing package (auto-fills price and revision
//  limit) and a saved client (auto-fills name and contact).
//

import SwiftUI
import SwiftData

struct AddEditCommissionView: View {
    var commission: Commission?
    var prefilledClient: Client? = nil

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Client.name) private var clients: [Client]
    @Query(sort: \PricingPackage.name) private var packages: [PricingPackage]

    @State private var clientName: String = ""
    @State private var clientContact: String = ""
    @State private var priceText: String = ""
    @State private var isDepositPaid: Bool = false
    @State private var depositPercentage: Double = 0
    @State private var deadline: Date = .now
    @State private var revisionLimit: Int = 2
    @State private var notes: String = ""
    @State private var selectedPackageID: PersistentIdentifier?

    private var isEditing: Bool { commission != nil }
    private var trimmedName: String { clientName.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        NavigationStack {
            Form {
                // Package picker (only when creating a new commission)
                if !isEditing && !packages.isEmpty {
                    Section("Package") {
                        packageRow
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }

                Section("Client") {
                    // Quick-fill from a saved client
                    if !isEditing && !clients.isEmpty {
                        Menu("Choose saved client") {
                            ForEach(clients) { client in
                                Button(client.name) {
                                    clientName = client.name
                                    clientContact = client.contact
                                }
                            }
                        }
                    }
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
                        .disabled(trimmedName.isEmpty)
                }
            }
            .onAppear(perform: loadInitialValues)
        }
    }

    // MARK: - Package chips

    private var packageRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(packages) { package in
                    chip(
                        title: package.name,
                        subtitle: "\(package.price.formatted(.currency(code: "PHP"))) · \(package.revisionLimit) rev",
                        isSelected: selectedPackageID == package.persistentModelID
                    ) {
                        selectedPackageID = package.persistentModelID
                        priceText = priceString(package.price)
                        revisionLimit = package.revisionLimit
                    }
                }

                chip(title: "Custom", subtitle: "Manual", isSelected: selectedPackageID == nil) {
                    selectedPackageID = nil
                }
            }
        }
    }

    private func chip(title: String, subtitle: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 12))
            }
            .foregroundStyle(isSelected ? Color.white : Theme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Theme.smallCornerRadius, style: .continuous)
                    .fill(isSelected ? Theme.textPrimary : Theme.badgeInactive.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func priceString(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
    }

    private func loadInitialValues() {
        if let commission {
            clientName = commission.clientName
            clientContact = commission.clientContact
            priceText = priceString(commission.price)
            isDepositPaid = commission.isDepositPaid
            depositPercentage = commission.depositPercentage
            deadline = commission.deadline
            revisionLimit = commission.revisionLimit
            notes = commission.notes
        } else if let prefilledClient {
            clientName = prefilledClient.name
            clientContact = prefilledClient.contact
        }
    }

    private func save() {
        let price = Double(priceText) ?? 0
        let controller = CommissionController(context: context)

        if let commission {
            controller.updateCommission(
                commission,
                clientName: trimmedName,
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
                clientName: trimmedName,
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
        .modelContainer(for: [Commission.self, Client.self, Payment.self, PricingPackage.self, ActivityLogEntry.self], inMemory: true)
}
