import Foundation

struct TrainingDrill: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let category: DrillCategory
    var difficulty: DrillDifficulty?
    var positionFocus: PositionFocus?
    var videoUrl: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case difficulty
        case positionFocus = "position_focus"
        case videoUrl = "video_url"
        case createdAt = "created_at"
    }
}

enum DrillCategory: String, Codable, CaseIterable {
    case shooting = "Shooting"
    case ballHandling = "Ball-Handling"
    case defense = "Defense"
    case conditioning = "Conditioning"
    case passing = "Passing"
}

enum DrillDifficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum PositionFocus: String, Codable, CaseIterable {
    case guard = "Guard"
    case forward = "Forward"
    case center = "Center"
    case all = "All"
}
