import Foundation

struct UserMeasurables: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var heightInches: Int
    var weightLbs: Int
    var wingspanInches: Int?
    var verticalJumpInches: Int?
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case heightInches = "height_inches"
        case weightLbs = "weight_lbs"
        case wingspanInches = "wingspan_inches"
        case verticalJumpInches = "vertical_jump_inches"
        case updatedAt = "updated_at"
    }

    // Helper computed properties
    var heightFeet: Int {
        heightInches / 12
    }

    var heightRemainingInches: Int {
        heightInches % 12
    }

    var heightFormatted: String {
        "\(heightFeet)'\(heightRemainingInches)\""
    }
}
