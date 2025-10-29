import Foundation
import SwiftUI

extension Date {
    func formatted(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }

    func formattedShort() -> String {
        formatted(style: .short)
    }

    func formattedMedium() -> String {
        formatted(style: .medium)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func formatted(decimalPlaces: Int = 1) -> String {
        String(format: "%.\(decimalPlaces)f", self)
    }
}

extension Color {
    static let primaryOrange = Color("PrimaryOrange")
    static let navyBlue = Color("NavyBlue")
    static let successGreen = Color("SuccessGreen")
    static let backgroundGray = Color("BackgroundGray")
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
