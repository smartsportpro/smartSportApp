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
    let photoUrl: String?

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
        case photoUrl = "photo_url"
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

struct MatchResponse: Codable {
    let matches: [MatchResult]
}
