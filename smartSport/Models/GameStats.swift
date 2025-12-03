import Foundation

struct GameStats: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var gameDate: Date
    var opponentName: String?
    var minutesPlayed: Int?
    var points: Int?
    var rebounds: Int?
    var assists: Int?
    var steals: Int?
    var blocks: Int?
    var fgPercent: Double?
    var threePPercent: Double?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case gameDate = "date"
        case opponentName = "opponent"
        case minutesPlayed = "minutes"
        case points
        case rebounds
        case assists
        case steals
        case blocks
        case fgPercent = "fg_percent"
        case threePPercent = "three_percent"
        case createdAt = "created_at"
    }
}
