import Foundation

class MatchingService {
    static let shared = MatchingService()

    private let apiService = APIService.shared

    private init() {}

    func findMatches(
        userId: UUID? = nil,
        heightInches: Int? = nil,
        weightLbs: Int? = nil,
        position: Position? = nil,
        ppg: Double? = nil,
        apg: Double? = nil,
        rpg: Double? = nil,
        fgPercent: Double? = nil,
        targetDivision: Division? = nil
    ) async throws -> [MatchResult] {
        struct MatchRequest: Codable {
            let userId: UUID?
            let heightInches: Int?
            let weightLbs: Int?
            let position: String?
            let ppg: Double?
            let apg: Double?
            let rpg: Double?
            let fgPercent: Double?
            let targetDivision: String?

            enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case heightInches = "height_inches"
                case weightLbs = "weight_lbs"
                case position
                case ppg
                case apg
                case rpg
                case fgPercent = "fg_percent"
                case targetDivision = "target_division"
            }
        }

        let request = MatchRequest(
            userId: userId,
            heightInches: heightInches,
            weightLbs: weightLbs,
            position: position?.rawValue,
            ppg: ppg,
            apg: apg,
            rpg: rpg,
            fgPercent: fgPercent,
            targetDivision: targetDivision?.rawValue
        )

        let response: MatchResponse = try await apiService.request(
            endpoint: "/api/match",
            method: .post,
            body: request
        )

        return response.matches
    }
}
