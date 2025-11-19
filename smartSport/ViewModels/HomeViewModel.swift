//
//  HomeViewModel.swift
//  smartSport
//
//  Created by Claude Code on 2025-11-20.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var seasonAverages: UserStats?
    @Published var lastGame: GameStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let profileService = ProfileService.shared
    private let statsService = StatsService.shared

    func loadHomeData(userId: UUID) async {
        isLoading = true
        errorMessage = nil

        // Load data in parallel for better performance
        async let profileResult = loadProfile(userId: userId)
        async let statsResult = loadSeasonStats(userId: userId)
        async let lastGameResult = loadLastGame(userId: userId)

        _ = await (profileResult, statsResult, lastGameResult)
        isLoading = false
    }

    private func loadProfile(userId: UUID) async {
        do {
            userProfile = try await profileService.getProfile(userId: userId)
        } catch {
            print("Failed to load profile: \(error)")
        }
    }

    private func loadSeasonStats(userId: UUID) async {
        do {
            seasonAverages = try await profileService.getStats(userId: userId)
        } catch {
            print("Failed to load season stats: \(error)")
        }
    }

    private func loadLastGame(userId: UUID) async {
        do {
            let result = try await statsService.getUserStats(userId: userId)
            lastGame = result.games.first
        } catch {
            print("Failed to load last game: \(error)")
        }
    }
}
