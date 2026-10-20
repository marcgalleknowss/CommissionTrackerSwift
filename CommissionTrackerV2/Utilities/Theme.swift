//
//  Theme.swift
//  CommissionTracker
//
//  Centralized grayscale color palette + reusable style helpers.
//  Keeping this in one place means every screen stays visually
//  consistent (same grays, same corner radius, same spacing)
//  without repeating raw values everywhere.
//

import SwiftUI

enum Theme {

    // MARK: - Grayscale palette (no color accents, per design spec)
    static let background = Color(white: 0.98)      // app background, near-white
    static let cardBackground = Color.white          // card / glass surface base
    static let textPrimary = Color(white: 0.10)      // near-black, main text
    static let textSecondary = Color(white: 0.45)    // mid gray, subtitles/labels
    static let divider = Color(white: 0.85)          // hairline dividers
    static let badgeActive = Color(white: 0.15)      // "active" status pill (dark)
    static let badgeInactive = Color(white: 0.80)    // inactive/neutral pill (light)
    static let stroke = Color(white: 0.90)           // subtle border on inputs/cards

    // MARK: - Layout constants (8pt grid, iOS-accurate spacing)
    static let screenMargin: CGFloat = 16
    static let cardSpacing: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let cornerRadius: CGFloat = 20             // "squircle" style rounded corners
    static let smallCornerRadius: CGFloat = 12

    // MARK: - Reusable glass-style card background
    // Uses SwiftUI's built-in Material for a frosted/glass look
    // without needing any custom blur implementation.
    static func glassCard() -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(stroke, lineWidth: 0.5)
            )
    }
}

// Reusable modifier so every "card" view looks identical.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.cardPadding)
            .background(Theme.glassCard())
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
