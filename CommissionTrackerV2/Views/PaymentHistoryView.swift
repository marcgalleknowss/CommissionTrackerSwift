//
//  PaymentHistoryView.swift
//  CommissionTrackerV2
//
//  Itemized payment log for one commission, with a progress ring showing
//  how much has been paid. Payments are added through LogPaymentView and
//  removed by swiping left.
//

import SwiftUI
import SwiftData

struct PaymentHistoryView: View {
    let commission: Commission

    @Environment(\.modelContext) private var context
    @State private var isShowingLogPayment = false

    private var controller: CommissionController {
        CommissionController(context: context)
    }

    private var sortedPayments: [Payment] {
        commission.payments.sorted { $0.date > $1.date }
    }

    private var progress: Double {
        guard commission.price > 0 else { return 0 }
        return min(commission.totalPaid / commission.price, 1)
    }

    private var remaining: Double {
        max(commission.price - commission.totalPaid, 0)
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Theme.badgeInactive, lineWidth: 6)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Theme.textPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .frame(width: 72, height: 72)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Paid \(commission.totalPaid.formatted(.currency(code: "PHP")))")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Text("of \(commission.price.formatted(.currency(code: "PHP")))")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSecondary)
                        Text("Remaining \(remaining.formatted(.currency(code: "PHP")))")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Payments") {
                if sortedPayments.isEmpty {
                    Text("No payments logged yet")
                        .foregroundStyle(Theme.textSecondary)
                }

                ForEach(sortedPayments) { payment in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(payment.label.isEmpty ? "Payment" : payment.label)
                                .foregroundStyle(Theme.textPrimary)
                            Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        Text(payment.amount, format: .currency(code: "PHP"))
                            .monospacedDigit()
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            controller.deletePayment(payment)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Payments")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingLogPayment = true
                } label: {
                    Label("Log Payment", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingLogPayment) {
            LogPaymentView(commission: commission)
        }
    }
}

// MARK: - Log payment form
struct LogPaymentView: View {
    let commission: Commission

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var date: Date = .now
    @State private var label: String = ""

    private var amount: Double { Double(amountText) ?? 0 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Payment") {
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Label (e.g. Deposit, Milestone 2)", text: $label)
                }
            }
            .navigationTitle("Log Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(amount <= 0)
                }
            }
        }
    }

    private func save() {
        CommissionController(context: context).logPayment(
            for: commission,
            amount: amount,
            date: date,
            label: label.trimmingCharacters(in: .whitespaces)
        )
        dismiss()
    }
}
