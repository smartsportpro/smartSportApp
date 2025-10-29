import Foundation

struct UserStats: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var ppg: Double?
    var rpg: Double?
    var apg: Double?
    var fgPercent: Double?
    var threePPercent: Double?
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case ppg
        case rpg
        case apg
        case fgPercent = "fg_percent"
        case threePPercent = "three_p_percent"
        case updatedAt = "updated_at"
    }
}
