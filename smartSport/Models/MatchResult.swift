import Foundation

struct MatchResult: Codable, Identifiable {
    let playerId: UUID
    let name: String
    let college: String
    let division: Division
    let position: Position
    let similarityScore: Double
    let collegeHeightInches: Int
    let collegeWeightLbs: Int
    let hsPpg: Double?
    let hsApg: Double?
    let hsRpg: Double?
    let hsFgPercent: Double?
    let hs3pPercent: Double?
    let photoUrl: String?
    let videoUrl: String?

    var id: UUID { playerId }

    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case name
        case college
        case division
        case position
        case similarityScore = "similarity_score"
        case collegeHeightInches = "college_height_inches"
        case collegeWeightLbs = "college_weight_lbs"
        case hsPpg = "hs_ppg"
        case hsApg = "hs_apg"
        case hsRpg = "hs_rpg"
        case hsFgPercent = "hs_fg_percent"
        case hs3pPercent = "hs_3p_percent"
        case photoUrl = "photo_url"
        case videoUrl = "video_url"
    }

    var heightFeet: Int {
        collegeHeightInches / 12
    }

    var heightRemainingInches: Int {
        collegeHeightInches % 12
    }

    var heightFormatted: String {
        "\(heightFeet)'\(heightRemainingInches)\""
    }

    var similarityPercentFormatted: String {
        String(format: "%.0f%%", similarityScore)
    }
}

struct UserStatsSnapshot: Codable {
    let ppg: Double?
    let apg: Double?
    let rpg: Double?
    let fgPercent: Double?

    enum CodingKeys: String, CodingKey {
        case ppg
        case apg
        case rpg
        case fgPercent = "fg_percent"
    }
}

struct MatchResponse: Codable {
    let matches: [MatchResult]
    let userStats: UserStatsSnapshot?

    enum CodingKeys: String, CodingKey {
        case matches
        case userStats = "user_stats"
    }
}
