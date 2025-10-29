import Foundation

struct Validators {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }

    static func isValidHeight(_ heightInches: Int) -> Bool {
        return heightInches >= 48 && heightInches <= 96
    }

    static func isValidWeight(_ weightLbs: Int) -> Bool {
        return weightLbs >= 80 && weightLbs <= 400
    }

    static func isValidStatPercentage(_ percent: Double) -> Bool {
        return percent >= 0 && percent <= 100
    }

    static func isValidStatValue(_ value: Double, min: Double = 0, max: Double = 100) -> Bool {
        return value >= min && value <= max
    }
}
