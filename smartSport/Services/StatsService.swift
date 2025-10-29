import Foundation

class StatsService {
    static let shared = StatsService()

    private let apiService = APIService.shared

    private init() {}

    func addGameStats(_ gameStats: GameStats) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: "/api/stats",
            method: .post,
            body: gameStats
        )
    }

    func getUserStats(userId: UUID) async throws -> (games: [GameStats], seasonAverages: UserStats) {
        struct StatsResponse: Codable {
            let games: [GameStats]
            let seasonAverages: UserStats

            enum CodingKeys: String, CodingKey {
                case games
                case seasonAverages = "season_averages"
            }
        }

        let response: StatsResponse = try await apiService.request(
            endpoint: "/api/stats/\(userId.uuidString)",
            method: .get
        )

        return (response.games, response.seasonAverages)
    }

    func deleteGame(gameId: UUID) async throws {
        let _: EmptyResponse = try await apiService.request(
            endpoint: "/api/stats/\(gameId.uuidString)",
            method: .delete
        )
    }
}

struct EmptyResponse: Codable {}
