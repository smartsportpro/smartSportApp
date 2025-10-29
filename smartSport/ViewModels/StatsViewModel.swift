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
            let result = try await statsService.getUserStats(userId: userId)
            games = result.games
            seasonAverages = result.seasonAverages
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func addGame(_ game: GameStats) async {
        isLoading = true
        errorMessage = nil

        do {
            try await statsService.addGameStats(game)
            await loadStats(userId: game.userId)
        } catch {
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
