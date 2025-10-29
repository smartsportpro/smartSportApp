import Foundation

struct CollegePlayer: Codable, Identifiable {
    let id: UUID
    let name: String
    let collegeName: String
    let divisionLevel: Division
    let position: Position
    let collegeHeightInches: Int
    let collegeWeightLbs: Int
    var highSchoolName: String?
    var hsSeniorPpg: Double?
    var hsSeniorRpg: Double?
    var hsSeniorApg: Double?
    var hsSeniorFgPercent: Double?
    var hsSenior3pPercent: Double?
    var photoUrl: String?
    var videoAvailability: String?
    var youtubeSearchHint: String?
    var dataSource: String?
    var notes: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case collegeName = "college_name"
        case divisionLevel = "division_level"
        case position
        case collegeHeightInches = "college_height_inches"
        case collegeWeightLbs = "college_weight_lbs"
        case highSchoolName = "high_school_name"
        case hsSeniorPpg = "hs_senior_ppg"
        case hsSeniorRpg = "hs_senior_rpg"
        case hsSeniorApg = "hs_senior_apg"
        case hsSeniorFgPercent = "hs_senior_fg_percent"
        case hsSenior3pPercent = "hs_senior_3p_percent"
        case photoUrl = "photo_url"
        case videoAvailability = "video_availability"
        case youtubeSearchHint = "youtube_search_hint"
        case dataSource = "data_source"
        case notes
        case createdAt = "created_at"
    }

    // Helper computed properties
    var heightFeet: Int {
        collegeHeightInches / 12
    }

    var heightRemainingInches: Int {
        collegeHeightInches % 12
    }

    var heightFormatted: String {
        "\(heightFeet)'\(heightRemainingInches)\""
    }
}
