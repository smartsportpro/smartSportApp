import Foundation

class VideoService {
    static let shared = VideoService()

    private let apiService = APIService.shared

    private init() {}

    func searchVideos(
        playerName: String,
        highSchool: String? = nil,
        collegeName: String? = nil,
        divisionLevel: Division? = nil,
        position: Position? = nil
    ) async throws -> [Video] {
        struct VideoSearchRequest: Codable {
            let playerName: String
            let highSchool: String?
            let collegeName: String?
            let divisionLevel: String?
            let position: String?

            enum CodingKeys: String, CodingKey {
                case playerName = "player_name"
                case highSchool = "high_school"
                case collegeName = "college_name"
                case divisionLevel = "division_level"
                case position
            }
        }

        let request = VideoSearchRequest(
            playerName: playerName,
            highSchool: highSchool,
            collegeName: collegeName,
            divisionLevel: divisionLevel?.rawValue,
            position: position?.rawValue
        )

        let response: VideoSearchResponse = try await apiService.request(
            endpoint: "/api/videos/search",
            method: .post,
            body: request
        )

        return response.videos
    }
}
