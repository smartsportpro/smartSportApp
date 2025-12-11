import SwiftUI

// MARK: - Design System for SmartSport App
// Created for SMART-157: Unify and Polish UI Design
// This file contains reusable design tokens and modifiers for consistent UI

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDisabled ? Color.gray : Color.primaryOrange)
            .foregroundColor(.white)
            .cornerRadius(CornerRadius.button)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.secondarySystemBackground))
            .foregroundColor(.primaryOrange)
            .cornerRadius(CornerRadius.button)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(CornerRadius.button)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Card Modifier

struct CardModifier: ViewModifier {
    var useShadow: Bool = true
    var backgroundColor: Color = Color(.systemBackground)

    func body(content: Content) -> some View {
        content
            .padding(Spacing.lg)
            .background(backgroundColor)
            .cornerRadius(CornerRadius.card)
            .shadow(
                color: useShadow ? .black.opacity(0.08) : .clear,
                radius: useShadow ? 8 : 0,
                x: 0,
                y: useShadow ? 4 : 0
            )
    }
}

extension View {
    /// Applies standard card styling with optional shadow
    /// - Parameter shadow: Whether to include shadow (default: true)
    func cardStyle(shadow: Bool = true) -> some View {
        modifier(CardModifier(useShadow: shadow))
    }

    /// Applies secondary card styling (gray background, no shadow)
    func secondaryCardStyle() -> some View {
        modifier(CardModifier(useShadow: false, backgroundColor: Color(.secondarySystemBackground)))
    }
}

// MARK: - Spacing Constants (8pt Grid System)

struct Spacing {
    /// 4pt - Minimal spacing (tight VStacks, icon+text)
    static let xs: CGFloat = 4

    /// 8pt - Card internal spacing
    static let sm: CGFloat = 8

    /// 12pt - Section spacing (between elements in same group)
    static let md: CGFloat = 12

    /// 16pt - Card padding
    static let lg: CGFloat = 16

    /// 20pt - Section separation (between major sections)
    static let xl: CGFloat = 20

    /// 24pt - Screen-level spacing (ScrollView VStack spacing)
    static let xxl: CGFloat = 24

    /// 40pt - Empty state icon bottom margin
    static let emptyState: CGFloat = 40
}

// MARK: - Corner Radius Constants

struct CornerRadius {
    /// 8pt - Input fields
    static let input: CGFloat = 8

    /// 12pt - Standard cards and buttons
    static let card: CGFloat = 12
    static let button: CGFloat = 12

    /// 20pt - Modal overlays and success messages
    static let modal: CGFloat = 20
}

// MARK: - Icon Sizes

struct IconSize {
    /// 60pt - Empty state icons
    static let emptyState: CGFloat = 60

    /// 20pt - Category icons in circles
    static let category: CGFloat = 20

    /// 30pt - Medium icons (avatars, etc.)
    static let medium: CGFloat = 30

    /// 80pt - Large decorative icons
    static let large: CGFloat = 80
}

// MARK: - Typography Helpers

extension Font {
    /// Standard button text font
    static let buttonText = Font.body.weight(.semibold)

    /// Card title font
    static let cardTitle = Font.title2.weight(.bold)

    /// Stat value font (large)
    static let statValueLarge = Font.title2.weight(.bold)

    /// Stat value font (small)
    static let statValueSmall = Font.title3.weight(.semibold)

    /// Section header font
    static let sectionHeader = Font.headline
}
