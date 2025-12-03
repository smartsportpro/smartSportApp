import Foundation
import SwiftUI

@MainActor
class StatsViewModel: ObservableObject {
    @Published var games: [GameStats] = []
    @Published var seasonAverages: UserStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let statsService = StatsService.shared

    func loadStats(userId: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            print("📊 Loading stats for user: \(userId)")
            let result = try await statsService.getUserStats(userId: userId)
            print("✅ Stats loaded successfully: \(result.games.count) games, seasonAverages: \(result.seasonAverages != nil)")
            games = result.games
            seasonAverages = result.seasonAverages
        } catch {
            print("❌ Error loading stats: \(error)")
            print("❌ Error type: \(type(of: error))")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func addGame(_ game: GameStats) async {
        isLoading = true
        errorMessage = nil

        do {
            print("📝 Adding game for user: \(game.userId)")
            try await statsService.addGameStats(game)
            print("✅ Game added successfully")
            await loadStats(userId: game.userId)
        } catch {
            print("❌ Error adding game: \(error)")
            print("❌ Error type: \(type(of: error))")
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteGame(_ game: GameStats) async {
        isLoading = true
        errorMessage = nil

        do {
            try await statsService.deleteGame(gameId: game.id)
            games.removeAll { $0.id == game.id }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
