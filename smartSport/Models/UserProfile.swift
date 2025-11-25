import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var name: String
    var age: Int?
    var position: Position?
    var targetDivision: Division?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case age
        case position
        case targetDivision = "target_division"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum Position: String, Codable, CaseIterable {
    // User positions (specific)
    case pg = "PG"
    case sg = "SG"
    case sf = "SF"
    case pf = "PF"
    case c = "C"

    // College positions (general) - used by matching algorithm
    case `guard` = "Guard"
    case forward = "Forward"
    case big = "Big"

    var fullName: String {
        switch self {
        case .pg: return "Point Guard"
        case .sg: return "Shooting Guard"
        case .sf: return "Small Forward"
        case .pf: return "Power Forward"
        case .c: return "Center"
        case .`guard`: return "Guard"
        case .forward: return "Forward"
        case .big: return "Big"
        }
    }

    var numericValue: Int {
        switch self {
        case .pg: return 1
        case .sg: return 2
        case .sf: return 3
        case .pf: return 4
        case .c: return 5
        case .`guard`: return 1
        case .forward: return 2
        case .big: return 3
        }
    }

    // Convert user position to college position for matching
    var collegePosition: Position {
        switch self {
        case .pg, .sg: return .`guard`
        case .sf, .pf: return .forward
        case .c: return .big
        case .`guard`, .forward, .big: return self
        }
    }
}

enum Division: String, Codable, CaseIterable {
    case d1 = "D1"
    case d2 = "D2"
    case d3 = "D3"
    case naia = "NAIA"
}
