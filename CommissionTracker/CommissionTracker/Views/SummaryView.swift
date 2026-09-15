//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
//

import SwiftUI

struct SummaryView: View {
    let commission: Commission
    @Environment(\.dismiss) private var dismiss


    private var shareText: String {
        """
        Commission Summary
        Client: \(commission.clientName)
        Price: \(commission.price.formatted(.currency(code: "PHP")))
        Deposit paid: \(commission.isDepositPaid ? "\(Int(commission.depositPercentage))%" : "No")
        Balance due: \(commission.balanceDue.formatted(.currency(code: "PHP")))
        Status: \(commission.stage.rawValue)
        Deadline: \(commission.deadline.formatted(date: .abbreviated, time: .omitted))
        """
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Commission Summary")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    Divider().background(Theme.divider)

                    summaryRow(label: "Client", value: commission.clientName)
                    summaryRow(label: "Status", value: commission.stage.rawValue)
                    summaryRow(label: "Deadline", value: commission.deadline.formatted(date: .abbreviated, time: .omitted))

                    Divider().background(Theme.divider)

                    summaryRow(label: "Price", value: commission.price.formatted(.currency(code: "PHP")))
                    summaryRow(
                        label: "Deposit",
                        value: commission.isDepositPaid ? "\(Int(commission.depositPercentage))% paid" : "Not paid"
                    )

                    Divider().background(Theme.divider)

                    summaryRow(
                        label: "Balance due",
                        value: commission.balanceDue.formatted(.currency(code: "PHP")),
                        emphasized: true
                    )
                }
                .cardStyle()

                Spacer()

                ShareLink(item: shareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous).fill(Theme.textPrimary))
                }
            }
            .padding(Theme.screenMargin)
            .background(Theme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func summaryRow(label: String, value: String, emphasized: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: emphasized ? .bold : .medium, design: .default))
                .monospacedDigit()
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

#Preview {
    SummaryView(commission: Commission(clientName: "Jane Dela Cruz", price: 1500, deadline: .now))
}
