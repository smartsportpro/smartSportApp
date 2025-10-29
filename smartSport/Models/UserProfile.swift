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
    case pg = "PG"
    case sg = "SG"
    case sf = "SF"
    case pf = "PF"
    case c = "C"

    var fullName: String {
        switch self {
        case .pg: return "Point Guard"
        case .sg: return "Shooting Guard"
        case .sf: return "Small Forward"
        case .pf: return "Power Forward"
        case .c: return "Center"
        }
    }

    var numericValue: Int {
        switch self {
        case .pg: return 1
        case .sg: return 2
        case .sf: return 3
        case .pf: return 4
        case .c: return 5
        }
    }
}

enum Division: String, Codable, CaseIterable {
    case d1 = "D1"
    case d2 = "D2"
    case d3 = "D3"
    case naia = "NAIA"
}
