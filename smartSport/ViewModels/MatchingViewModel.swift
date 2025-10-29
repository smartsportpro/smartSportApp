import Foundation
import SwiftUI

@MainActor
class MatchingViewModel: ObservableObject {
    @Published var matches: [MatchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let matchingService = MatchingService.shared
    private let videoService = VideoService.shared

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
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            matches = try await matchingService.findMatches(
                userId: userId,
                heightInches: heightInches,
                weightLbs: weightLbs,
                position: position,
                ppg: ppg,
                apg: apg,
                rpg: rpg,
                fgPercent: fgPercent,
                targetDivision: targetDivision
            )
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func searchVideosForPlayer(
        playerName: String,
        highSchool: String? = nil,
        collegeName: String? = nil,
        divisionLevel: Division? = nil,
        position: Position? = nil
    ) async -> [Video] {
        do {
            return try await videoService.searchVideos(
                playerName: playerName,
                highSchool: highSchool,
                collegeName: collegeName,
                divisionLevel: divisionLevel,
                position: position
            )
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
}
