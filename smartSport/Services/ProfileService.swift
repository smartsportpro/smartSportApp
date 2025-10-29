import Foundation

class ProfileService {
    static let shared = ProfileService()

    private let apiService = APIService.shared

    private init() {}

    func createProfile(_ profile: UserProfile) async throws -> UserProfile {
        return try await apiService.request(
            endpoint: "/api/profile",
            method: .post,
            body: profile
        )
    }

    func getProfile(userId: UUID) async throws -> UserProfile {
        return try await apiService.request(
            endpoint: "/api/profile/\(userId.uuidString)",
            method: .get
        )
    }

    func updateProfile(_ profile: UserProfile) async throws -> UserProfile {
        return try await apiService.request(
            endpoint: "/api/profile/\(profile.userId.uuidString)",
            method: .put,
            body: profile
        )
    }

    func updateMeasurables(_ measurables: UserMeasurables) async throws -> UserMeasurables {
        return try await apiService.request(
            endpoint: "/api/profile/\(measurables.userId.uuidString)/measurables",
            method: .put,
            body: measurables
        )
    }

    func updateStats(_ stats: UserStats) async throws -> UserStats {
        return try await apiService.request(
            endpoint: "/api/profile/\(stats.userId.uuidString)/stats",
            method: .put,
            body: stats
        )
    }
}
