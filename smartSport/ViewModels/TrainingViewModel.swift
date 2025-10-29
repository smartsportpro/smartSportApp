import Foundation
import SwiftUI

@MainActor
class TrainingViewModel: ObservableObject {
    @Published var recommendedDrills: [TrainingDrill] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let trainingService = TrainingService.shared

    func loadRecommendations(
        userId: UUID? = nil,
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
            recommendedDrills = try await trainingService.recommendDrills(
                userId: userId,
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

    func refreshRecommendations(
        userId: UUID? = nil,
        position: Position? = nil,
        ppg: Double? = nil,
        apg: Double? = nil,
        rpg: Double? = nil,
        fgPercent: Double? = nil,
        targetDivision: Division? = nil
    ) async {
        await loadRecommendations(
            userId: userId,
            position: position,
            ppg: ppg,
            apg: apg,
            rpg: rpg,
            fgPercent: fgPercent,
            targetDivision: targetDivision
        )
    }
}
