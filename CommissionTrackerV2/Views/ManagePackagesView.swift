//
//  ManagePackagesView.swift
//  CommissionTrackerV2
//
//  Lets the artist create and delete reusable pricing packages.
//  Opened from Settings (pushed inside Settings' NavigationStack).
//

import SwiftUI
import SwiftData

struct ManagePackagesView: View {
    @Query(sort: \PricingPackage.name) private var packages: [PricingPackage]
    @Environment(\.modelContext) private var context

    @State private var isShowingAddSheet = false

    var body: some View {
        List {
            if packages.isEmpty {
                Text("No packages yet. Tap + to add one, e.g. \"Sketch Only\".")
                    .foregroundStyle(Theme.textSecondary)
            }

            ForEach(packages) { package in
                VStack(alignment: .leading, spacing: 4) {
                    Text(package.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textPrimary)
                    Text("\(package.price.formatted(.currency(code: "PHP"))) · \(package.revisionLimit) revisions")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .onDelete { offsets in
                let controller = PackageController(context: context)
                for index in offsets {
                    controller.deletePackage(packages[index])
                }
            }
        }
        .navigationTitle("Packages")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            AddPackageView()
        }
    }
}

// MARK: - Add package form
struct AddPackageView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var priceText: String = ""
    @State private var revisionLimit: Int = 2

    private var trimmedName: String { name.trimmingCharacters(in: .whitespaces) }
    private var price: Double { Double(priceText) ?? 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Package") {
                    TextField("Name (e.g. Full Color)", text: $name)
                    TextField("Price", text: $priceText)
                        .keyboardType(.decimalPad)
                    Stepper("Included revisions: \(revisionLimit)", value: $revisionLimit, in: 0...10)
                }
            }
            .navigationTitle("New Package")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(trimmedName.isEmpty || price <= 0)
                }
            }
        }
    }

    private func save() {
        PackageController(context: context).addPackage(
            name: trimmedName,
            price: price,
            revisionLimit: revisionLimit
        )
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ManagePackagesView()
    }
    .modelContainer(for: [Commission.self, Client.self, Payment.self, PricingPackage.self, ActivityLogEntry.self], inMemory: true)
}
