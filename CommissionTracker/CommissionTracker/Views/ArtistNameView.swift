//
//  CommissionTrackerApp.swift
//  CommissionTracker
//
//  Created by Mac-LAB on 9/3/26.
//


import SwiftUI

struct ArtistNameView: View {
    @Binding var artistName: String
    var onContinue: () -> Void

    // Local draft text so we don't write to storage on every keystroke.
    @State private var draftName: String = ""
    @FocusState private var isFieldFocused: Bool

    private var canContinue: Bool {
        !draftName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text("What should we call you?")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.center)

                
                VStack(spacing: 6) {
                    TextField("Your name", text: $draftName)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                        .focused($isFieldFocused)
                        .submitLabel(.done)

                    Rectangle()
                        .fill(Theme.divider)
                        .frame(height: 1)
                        .padding(.horizontal, 60)
                }

                Spacer()

                Button(action: {
                    artistName = draftName.trimmingCharacters(in: .whitespaces)
                    onContinue()
                }) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                                .fill(canContinue ? Theme.textPrimary : Theme.badgeInactive)
                        )
                }
                .disabled(!canContinue)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, Theme.screenMargin)
        }
        .onAppear { isFieldFocused = true }
    }
}

#Preview {
    ArtistNameView(artistName: .constant(""), onContinue: {})
}
