import Foundation
import SwiftUI

@MainActor
class TrainingViewModel: ObservableObject {
    @Published var recommendedDrills: [TrainingDrill] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isGenericPlan = false  // True if recommendations are generic (user has no stats)

    private let trainingService = TrainingService.shared
    private let authService = AuthService.shared

    // Convenience method that fetches current user
    func loadRecommendationsForCurrentUser() async {
        do {
            // Get current user
            guard let user = try await authService.getCurrentUser() else {
                errorMessage = "Please log in to get personalized recommendations"
                return
            }

            // Load recommendations using user_id
            await loadRecommendations(userId: user.id)
        } catch {
            errorMessage = "Failed to load user: \(error.localizedDescription)"
        }
    }

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
            let result = try await trainingService.recommendDrills(
                userId: userId,
                position: position,
                ppg: ppg,
                apg: apg,
                rpg: rpg,
                fgPercent: fgPercent,
                targetDivision: targetDivision
            )
            recommendedDrills = result.drills
            isGenericPlan = result.isGeneric
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshRecommendations() async {
        // Refresh using the current user
        await loadRecommendationsForCurrentUser()
    }
}
