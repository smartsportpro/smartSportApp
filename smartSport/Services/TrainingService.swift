import Foundation

class TrainingService {
    static let shared = TrainingService()

    private let apiService = APIService.shared

    private init() {}

    func recommendDrills(
        userId: UUID? = nil,
        position: Position? = nil,
        ppg: Double? = nil,
        apg: Double? = nil,
        rpg: Double? = nil,
        fgPercent: Double? = nil,
        targetDivision: Division? = nil
    ) async throws -> [TrainingDrill] {
        struct DrillRecommendationRequest: Codable {
            let userId: UUID?
            let position: String?
            let ppg: Double?
            let apg: Double?
            let rpg: Double?
            let fgPercent: Double?
            let targetDivision: String?

            enum CodingKeys: String, CodingKey {
                case userId = "user_id"
                case position
                case ppg
                case apg
                case rpg
                case fgPercent = "fg_percent"
                case targetDivision = "target_division"
            }
        }

        struct DrillRecommendationResponse: Codable {
            let drills: [TrainingDrill]
        }

        let request = DrillRecommendationRequest(
            userId: userId,
            position: position?.rawValue,
            ppg: ppg,
            apg: apg,
            rpg: rpg,
            fgPercent: fgPercent,
            targetDivision: targetDivision?.rawValue
        )

        let response: DrillRecommendationResponse = try await apiService.request(
            endpoint: "/api/drills/recommend",
            method: .post,
            body: request
        )

        return response.drills
    }
}
