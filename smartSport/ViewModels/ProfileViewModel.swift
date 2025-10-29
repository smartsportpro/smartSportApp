import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var measurables: UserMeasurables?
    @Published var stats: UserStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let profileService = ProfileService.shared

    func loadProfile(userId: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            profile = try await profileService.getProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createProfile(
        userId: UUID,
        name: String,
        age: Int?,
        position: Position?,
        targetDivision: Division?
    ) async {
        isLoading = true
        errorMessage = nil

        let newProfile = UserProfile(
            id: UUID(),
            userId: userId,
            name: name,
            age: age,
            position: position,
            targetDivision: targetDivision,
            createdAt: Date(),
            updatedAt: Date()
        )

        do {
            profile = try await profileService.createProfile(newProfile)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateProfile(_ updatedProfile: UserProfile) async {
        isLoading = true
        errorMessage = nil

        do {
            profile = try await profileService.updateProfile(updatedProfile)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateMeasurables(_ updatedMeasurables: UserMeasurables) async {
        isLoading = true
        errorMessage = nil

        do {
            measurables = try await profileService.updateMeasurables(updatedMeasurables)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateStats(_ updatedStats: UserStats) async {
        isLoading = true
        errorMessage = nil

        do {
            stats = try await profileService.updateStats(updatedStats)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
